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
 ["../shared/value.rkt" (num-val proc-val null-val)]
 ["../shared/parser.rkt" (scan&parse)]
 ["continuation.rkt" (
                      end-cont
                      apply-cont
                      diff-cont
                      zero?-cont
                      if-cont
                      exps-cont
                      let-cont
                      call-cont
                      cons-cont
                      null?-cont
                      car-cont
                      cdr-cont
                      list-cont
                      begin-cont
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
              (value-of/k exp1 env (diff-cont cont exp2 env))
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
             (value-of-exps/k exps env (let-cont cont vars body env))
             )
    (proc-exp (first-var rest-vars body)
              (apply-cont cont (proc-val (procedure (cons first-var rest-vars) body env)))
              )
    (call-exp (rator rands)
              (value-of/k rator env (call-cont cont rands env))
              )
    (letrec-exp (p-names b-vars-list p-bodies body)
                (let ((new-env (build-circular-extend-env-rec-mul-vec p-names b-vars-list p-bodies env)))
                  (value-of/k body new-env cont)
                  )
                )
    ; list
    (emptylist-exp () (apply-cont cont (null-val)))
    (cons-exp (exp1 exp2)
              (value-of/k exp1 env (cons-cont cont exp2 env))
              )
    (null?-exp (exp1)
               (value-of/k exp1 env (null?-cont cont))
               )
    (car-exp (exp1)
             (value-of/k exp1 env (car-cont cont))
             )
    (cdr-exp (exp1)
             (value-of/k exp1 env (cdr-cont cont))
             )
    (list-exp (exp1 exps)
              (value-of-exps/k (cons exp1 exps) env (list-cont cont))
              )
    (begin-exp (exp1 exps)
               (value-of-exps/k (cons exp1 exps) env (begin-cont cont))
               )
    (assign-exp (var exp1)
                (value-of/k exp1 env (set-rhs-cont cont (apply-env env var)))
                )
    (else (eopl:error "invalid exp ~s" exp))
    )
  )

(define (value-of-exps/k exps saved-env saved-cont)
  (value-of-exps-helper/k exps '() saved-env saved-cont)
  )

(define (value-of-exps-helper/k exps vals saved-env saved-cont)
  (if (null? exps)
      (apply-cont saved-cont vals)
      (let ((first-exp (car exps)) (rest-exps (cdr exps)))
        (value-of/k
         first-exp
         saved-env
         (lambda (val)
           (value-of-exps-helper/k rest-exps (append vals (list val)) saved-env saved-cont)
           )
         )
        )
      )
  )
