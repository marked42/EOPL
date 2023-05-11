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
 ["../shared/value.rkt" (mutex-val num-val)]
 ["../shared/eval.rkt" (
                        eval-const-exp
                        eval-var-exp
                        eval-proc-exp
                        eval-letrec-exp
                        eval-emptylist-exp
                        )]
 ["continuation.rkt" (
                      end-main-thread-cont
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
                      spawn-cont
                      wait-cont
                      signal-cont
                      print-cont
                      yield-cont
                      )]
 ["call.rkt" (eval-operand-call-by-value)]
 ["scheduler.rkt" (initialize-scheduler!)]
 ["mutex.rkt" (new-mutex)]
 )

(provide (all-defined-out))

(define (run str)
  (value-of-program 10 (scan&parse str))
  )

(define (value-of-program timeslice prog)
  (initialize-store!)
  (initialize-scheduler! timeslice)
  (cases program prog
    (a-program (exp1) (value-of/k exp1 (init-env) (end-main-thread-cont)))
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
             (value-of-exps/k exps env (let-cont cont vars body env) eval-operand-call-by-value)
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
              (value-of-exps/k (cons exp1 exps) env (list-cont cont) eval-operand-call-by-value)
              )
    (begin-exp (exp1 exps)
               (value-of-exps/k (cons exp1 exps) env (begin-cont cont) eval-operand-call-by-value)
               )
    (assign-exp (var exp1)
                (value-of/k exp1 env (set-rhs-cont cont (apply-env env var)))
                )
    (spawn-exp (exp1) (value-of/k exp1 env (spawn-cont cont)))
    (mutex-exp () (apply-cont cont (mutex-val (new-mutex))))
    (wait-exp (exp1) (value-of/k exp1 env (wait-cont cont)))
    (signal-exp (exp1) (value-of/k exp1 env (signal-cont cont)))
    (print-exp (exp1) (value-of/k exp1 env (print-cont cont)))
    ; num-val -99 is unused dummy value
    (yield-exp () (apply-cont (yield-cont cont) (num-val -99)))
    (else (eopl:error "invalid exp ~s" exp))
    )
  )

(define (value-of-exps/k exps saved-env saved-cont mapper)
  (value-of-exps-helper/k exps '() saved-env saved-cont mapper)
  )

(define (value-of-exps-helper/k exps vals saved-env saved-cont mapper)
  (if (null? exps)
      (apply-cont saved-cont vals)
      (let ((first-exp (car exps)) (rest-exps (cdr exps)))
        (mapper first-exp saved-env
                (exps-cont saved-cont rest-exps vals saved-env mapper)
                )
        )
      )
  )
