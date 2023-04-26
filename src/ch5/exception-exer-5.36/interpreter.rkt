#lang eopl

(require
  racket/lazy-require
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
                      )]
 )

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  (initialize-store!)
  (let ((dummy-try-cont (end-cont)))
    (cases program prog
      (a-program (exp1) (value-of/k exp1 (init-env) (end-cont) dummy-try-cont))
      )
    )
  )

(define (value-of/k exp env cont try)
  (cases expression exp
    (const-exp (num) (apply-cont cont (eval-const-exp num) try))
    (diff-exp (exp1 exp2)
              (value-of/k exp1 env (diff-cont cont exp2 env) try)
              )
    (zero?-exp (exp1)
               (value-of/k exp1 env (zero?-cont cont) try)
               )
    (if-exp (exp1 exp2 exp3)
            (value-of/k exp1 env (if-cont cont exp2 exp3 env) try)
            )
    (var-exp (var)
             (apply-cont cont (eval-var-exp env var) try)
             )
    (let-exp (vars exps body)
             (value-of-exps/k exps env (let-cont cont vars body env) try)
             )
    (proc-exp (first-var rest-vars body)
              (apply-cont cont (eval-proc-exp first-var rest-vars body env) try)
              )
    (call-exp (rator rands)
              (value-of/k rator env (call-cont cont rands env) try)
              )
    (letrec-exp (p-names b-vars-list p-bodies body)
                (value-of/k body (eval-letrec-exp p-names b-vars-list p-bodies env) cont try)
                )
    ; list
    (emptylist-exp () (apply-cont cont (eval-emptylist-exp) try))
    (cons-exp (exp1 exp2)
              (value-of/k exp1 env (cons-cont cont exp2 env) try)
              )
    (null?-exp (exp1)
               (value-of/k exp1 env (null?-cont cont) try)
               )
    (car-exp (exp1)
             (value-of/k exp1 env (car-cont cont) try)
             )
    (cdr-exp (exp1)
             (value-of/k exp1 env (cdr-cont cont) try)
             )
    (list-exp (exp1 exps)
              (value-of-exps/k (cons exp1 exps) env (list-cont cont) try)
              )
    (begin-exp (exp1 exps)
               (value-of-exps/k (cons exp1 exps) env (begin-cont cont) try)
               )
    (assign-exp (var exp1)
                (value-of/k exp1 env (set-rhs-cont cont (apply-env env var)) try)
                )
    (try-exp (exp1 var handler-exp)
             (let ((new-try-cont (try-cont cont var handler-exp env try)))
               (value-of/k exp1 env new-try-cont new-try-cont)
               )
             )
    (raise-exp (exp1)
               (value-of/k exp1 env (raise-cont cont) try)
               )
    (else (eopl:error "invalid exp ~s" exp))
    )
  )

(define (value-of-exps/k exps saved-env saved-cont try)
  (value-of-exps-helper/k exps '() saved-env saved-cont try)
  )

(define (value-of-exps-helper/k exps vals saved-env saved-cont try)
  (if (null? exps)
      (apply-cont saved-cont vals try)
      (let ((first-exp (car exps)) (rest-exps (cdr exps)))
        (value-of/k first-exp saved-env
                    (exps-cont saved-cont rest-exps vals saved-env)
                    try
                    )
        )
      )
  )
