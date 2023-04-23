#lang eopl

(require racket/lazy-require "value.rkt" "parser.rkt" "expression.rkt")
(lazy-require
 ["basic.rkt" (identifier?)]
 ["environment.rkt" (init-env apply-env extend-env environment?)]
 ["procedure.rkt" (procedure apply-procedure/k)]
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

(define-datatype continuation cont?
  (end-cont)
  (diff-cont (saved-cont cont?) (exp2 expression?) (saved-env environment?))
  (diff-cont-1 (saved-cont cont?) (val1 expval?))
  (zero?-cont (saved-cont cont?))
  (if-cont (saved-cont cont?) (exp2 expression?) (exp3 expression?) (saved-env environment?))
  (let-cont (saved-cont cont?) (var identifier?) (body expression?) (env environment?))
  (call-cont (saved-cont cont?) (rands expression?) (saved-env environment?))
  (call-cont-1 (saved-cont cont?) (rator expval?))
  )

(define (apply-cont cont val)
  (cases continuation cont
    (end-cont () val)
    (diff-cont (saved-cont exp2 saved-env)
               (value-of/k exp2 saved-env (diff-cont-1 saved-cont val))
               )
    (diff-cont-1 (saved-cont val1)
                 (let ((num1 (expval->num val1)) (num2 (expval->num val)))
                   (apply-cont saved-cont (num-val (- num1 num2)))
                   )
                 )
    (zero?-cont (saved-cont)
                (apply-cont saved-cont
                            (let ((num (expval->num val)))
                              (if (zero? num)
                                  (bool-val #t)
                                  (bool-val #f)
                                  )
                              )
                            )
                )
    (if-cont (saved-cont exp2 exp3 saved-env)
             (value-of/k (if (expval->bool val) exp2 exp3) saved-env saved-cont)
             )
    (let-cont (saved-cont var body saved-env)
              (value-of/k body (extend-env var val saved-env) saved-cont)
              )
    (call-cont (saved-cont rand saved-env)
               (let ((rator val))
                 (value-of/k rand saved-env (call-cont-1 saved-cont rator))
                 )
               )
    (call-cont-1 (saved-cont rator)
                 (let ((proc1 (expval->proc rator)) (rand val))
                   (apply-procedure/k proc1 rand saved-cont)
                   )
                 )
    )
  )
