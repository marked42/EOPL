#lang eopl

(require racket/lazy-require "value.rkt" "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     )]
 ["procedure.rkt" (procedure)]
 ["continuation.rkt" (end-cont apply-cont diff-cont zero?-cont if-cont let-cont call-cont)]
 )

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  (cases program prog
    (a-program (exp1) (value-of/k exp1 (init-env) (end-cont)))
    )
  )

(define (value-of/k exp env cont)
  (cases expression exp
    ; number constant
    (const-exp (num) (apply-cont cont (num-val num)))
    ; subtraction of two numbers
    (diff-exp (exp1 exp2)
              (value-of/k exp1 env (diff-cont cont exp2 env))
              )
    ; true only if exp1 is number 0
    (zero?-exp (exp1)
               (value-of/k exp1 env (zero?-cont cont))
               )
    (if-exp (exp1 exp2 exp3)
            (value-of/k exp1 env (if-cont cont exp2 exp3 env))
            )
    (var-exp (var)
             (apply-cont cont (apply-env env var))
             )
    (let-exp (var exp1 body)
             (value-of/k exp1 env (let-cont cont var body env))
             )
    (proc-exp (var body)
              (apply-cont cont (proc-val (procedure var body env)))
              )
    (call-exp (rator rand)
              (value-of/k rator env (call-cont cont rand env))
              )
    (else 42)
    )
  )
