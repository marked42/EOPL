#lang eopl

(require
  racket/lazy-require
  racket/list
  ; use program and expression datatype
  "../shared/expression.rkt"
  )
(lazy-require
 ["../shared/store.rkt" (initialize-store! newref)]
 ["../shared/parser.rkt" (scan&parse)]
 ["environment.rkt" (init-env apply-env extend-env)]
 ["procedure.rkt" (cont-procedure)]
 ["value.rkt" (proc-val)]
 ["eval.rkt" (
              eval-const-exp
              eval-var-exp
              eval-proc-exp
              eval-letrec-exp
              eval-emptylist-exp
              )]
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
                      try-cont
                      raise-cont
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
    (const-exp (num) (apply-cont cont (eval-const-exp num)))
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
             (apply-cont cont (eval-var-exp env var))
             )
    (let-exp (vars exps body)
             (value-of-exps/k exps env (let-cont cont vars body env))
             )
    (proc-exp (first-var rest-vars body)
              (apply-cont cont (eval-proc-exp first-var rest-vars body env))
              )
    (call-exp (rator rands)
              (value-of/k rator env (call-cont cont rands env))
              )
    (letrec-exp (p-names b-vars-list p-bodies body)
                (value-of/k body (eval-letrec-exp p-names b-vars-list p-bodies env) cont)
                )
    ; list
    (emptylist-exp () (apply-cont cont (eval-emptylist-exp)))
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
    (try-exp (exp1 var handler-exp)
             (value-of/k exp1 env (try-cont cont var handler-exp env))
             )
    (raise-exp (exp1)
               (value-of/k exp1 env (raise-cont cont))
               )
    (letcc-exp (var body)
               (value-of/k body (extend-env var (newref (proc-val (cont-procedure cont))) env) cont)
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
        (value-of/k first-exp saved-env
                    (exps-cont saved-cont rest-exps vals saved-env)
                    )
        )
      )
  )
