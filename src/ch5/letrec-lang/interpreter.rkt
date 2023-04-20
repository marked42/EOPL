#lang eopl

(require
  racket/lazy-require
  racket/list
  ; use program and expression datatype
  "../shared/expression.rkt"
  )
(lazy-require
 ["../shared/procedure.rkt" (procedure)]
 ["../shared/environment.rkt" (
                               init-env
                               apply-env
                               build-circular-extend-env-rec-mul-vec
                               )]
 ["../shared/store.rkt" (deref initialize-store!)]
 ["../shared/value.rkt" (num-val proc-val null-val bool-val)]
 ["../shared/parser.rkt" (scan&parse)]
 ["continuation.rkt" (
                      end-cont
                      build-cont
                      apply-cont
                      diff-cont-1
                      diff-cont-2
                      zero?-cont
                      if-cont
                      exps-cont
                      let-cont
                      call-exp-cont
                      cons-exp-cont-1
                      operands-cont
                      begin-operands-cont
                      null?-exp-cont
                      car-exp-cont
                      cdr-exp-cont
                      list-exp-cont
                      begin-exp-cont
                      set-rhs-cont
                      )]
 )

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  (initialize-store!)
  (cases program prog
    (a-program (exp1) (value-of/k exp1 (init-env) (end-cont)))
    )
  )

(define (value-of/k exp env cont)
  (cases expression exp
    (const-exp (num) (apply-cont cont (num-val num)))
    (diff-exp (exp1 exp2)
              (value-of/k exp1 env (diff-cont-1 cont exp2 env))
              )
    (zero?-exp (exp1)
               (value-of/k exp1 env (zero?-cont cont))
               )
    (if-exp (exp1 exp2 exp3)
            (value-of/k exp1 env (if-cont cont exp2 exp3 env))
            )
    (var-exp (var)
             (apply-cont cont (deref (apply-env env var)))
             )
    (let-exp (vars exps body)
             (value-of-exps/k exps '() env (let-cont cont vars body env))
             )
    (proc-exp (first-var rest-vars body)
              (apply-cont cont (proc-val (procedure (cons first-var rest-vars) body env)))
              )
    (call-exp (rator rands)
              (value-of/k rator env (call-exp-cont cont rands env))
              )
    (letrec-exp (p-names b-vars-list p-bodies body)
                (let ((new-env (build-circular-extend-env-rec-mul-vec p-names b-vars-list p-bodies env)))
                  (value-of/k body new-env cont)
                  )
                )
    ; ; list
    ; (emptylist-exp () (apply-cont cont (null-val)))
    ; (cons-exp (exp1 exp2)
    ;           (value-of/k exp1 env (cons-exp-cont-1 cont exp2 env))
    ;           )
    ; (null?-exp (exp1)
    ;            (value-of/k exp1 env (null?-exp-cont cont))
    ;            )
    ; (car-exp (exp1)
    ;          (value-of/k exp1 env (car-exp-cont cont))
    ;          )
    ; (cdr-exp (exp1)
    ;          (value-of/k exp1 env (cdr-exp-cont cont))
    ;          )
    ; (list-exp (exp1 exps)
    ;           (value-of-exps/k (cons exp1 exps) '() env (list-exp-cont cont))
    ;           )
    ; (begin-exp (exp1 exps)
    ;            (value-of-begin-operands/k (cons exp1 exps) (bool-val #f) env cont)
    ;            )
    ; (assign-exp (var exp1)
    ;             (value-of/k exp1 env (set-rhs-cont (apply-env env var) cont))
    ;             )
    (else (eopl:error "invalid exp ~s" exp))
    )
  )

(define (value-of-exps/k exps vals env saved-cont)
  (if (null? exps)
      (apply-cont saved-cont vals)
      (let ((first-exp (car exps)) (rest-exps (cdr exps)))
        (value-of/k
         first-exp
         env
         (exps-cont saved-cont rest-exps vals env)
         )
        )
      )
  )

(define (value-of-operands/k exps vals env saved-cont)
  (if (null? exps)
      (apply-cont saved-cont vals)
      (let ((first-exp (car exps)) (rest-exps (cdr exps)))
        (cases expression first-exp
          (var-exp (var)
                   (let ((val (deref (apply-env env var))))
                     (value-of-operands/k rest-exps (append vals (list val)) env saved-cont)
                     )
                   )
          (else
           (value-of/k first-exp env
                       (operands-cont saved-cont rest-exps vals env)
                       )
           )
          )
        )
      )
  )

(define (value-of-begin-operands/k exps last-val env saved-cont)
  (if (null? exps)
      (apply-cont saved-cont last-val)
      (let ((first-exp (car exps)) (rest-exps (cdr exps)))
        (value-of/k
         first-exp
         env
         (begin-operands-cont saved-cont rest-exps last-val env)
         )
        )
      )
  )
