#lang eopl

(require
  racket/lazy-require
  racket/list
  ; use program and expression datatype
  "../shared/expression.rkt"
  )
(lazy-require
 ["../shared/environment.rkt" (init-env apply-env)]
 ["../shared/store.rkt" (initialize-store!)]
 ["../shared/parser.rkt" (scan&parse)]
 ["../shared/eval.rkt" (
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
                      get-saved-try-cont
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
  (let ((saved-try-cont (get-saved-try-cont cont)))
    (cases expression exp
      (const-exp (num) (apply-cont cont (eval-const-exp num)))
      (diff-exp (exp1 exp2)
                (value-of/k exp1 env (diff-cont cont saved-try-cont exp2 env))
                )
      (zero?-exp (exp1)
                (value-of/k exp1 env (zero?-cont cont saved-try-cont))
                )
      (if-exp (exp1 exp2 exp3)
              (value-of/k exp1 env (if-cont cont saved-try-cont exp2 exp3 env))
              )
      (var-exp (var)
              (apply-cont cont (eval-var-exp env var))
              )
      (let-exp (vars exps body)
              (value-of-exps/k exps env (let-cont cont saved-try-cont vars body env))
              )
      (proc-exp (first-var rest-vars body)
                (apply-cont cont (eval-proc-exp first-var rest-vars body env))
                )
      (call-exp (rator rands)
                (value-of/k rator env (call-cont cont saved-try-cont rands env))
                )
      (letrec-exp (p-names b-vars-list p-bodies body)
                  (value-of/k body (eval-letrec-exp p-names b-vars-list p-bodies env) cont)
                  )
      ; list
      (emptylist-exp () (apply-cont cont (eval-emptylist-exp)))
      (cons-exp (exp1 exp2)
                (value-of/k exp1 env (cons-cont cont saved-try-cont exp2 env))
                )
      (null?-exp (exp1)
                (value-of/k exp1 env (null?-cont cont saved-try-cont))
                )
      (car-exp (exp1)
              (value-of/k exp1 env (car-cont cont saved-try-cont))
              )
      (cdr-exp (exp1)
              (value-of/k exp1 env (cdr-cont cont saved-try-cont))
              )
      (list-exp (exp1 exps)
                (value-of-exps/k (cons exp1 exps) env (list-cont cont saved-try-cont))
                )
      (begin-exp (exp1 exps)
                (value-of-exps/k (cons exp1 exps) env (begin-cont cont saved-try-cont))
                )
      (assign-exp (var exp1)
                  (value-of/k exp1 env (set-rhs-cont cont saved-try-cont (apply-env env var)))
                  )
      (try-exp (exp1 var handler-exp)
              (value-of/k exp1 env (try-cont cont saved-try-cont var handler-exp env))
              )
      (raise-exp (exp1)
                (value-of/k exp1 env (raise-cont cont saved-try-cont))
                )
      (else (eopl:error "invalid exp ~s" exp))
      )
    )
  )

(define (value-of-exps/k exps saved-env saved-cont)
  (value-of-exps-helper/k exps '() saved-env saved-cont)
  )

(define (value-of-exps-helper/k exps vals saved-env saved-cont)
  (let ((saved-try-cont (get-saved-try-cont saved-cont)))
    (if (null? exps)
        (apply-cont saved-cont vals)
        (let ((first-exp (car exps)) (rest-exps (cdr exps)))
          (value-of/k first-exp saved-env
                  (exps-cont saved-cont saved-try-cont rest-exps vals saved-env)
                  )
          )
        )
    )
  )
