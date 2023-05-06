#lang eopl

(require racket/lazy-require "value.rkt" "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env
                     )]
 ["procedure.rkt" (apply-procedure procedure)])

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  (cases program prog
    (a-program (exp1) (value-of-exp exp1 (init-env)))
    )
  )

(define (value-of-exp exp env)
  (cases expression exp
    ; number constant
    (const-exp (num) (num-val num))
    ; subtraction of two numbers
    (diff-exp (exp1 exp2)
              (let ((val1 (value-of-exp exp1 env))
                    (val2 (value-of-exp exp2 env)))
                (let ((num1 (expval->num val1))
                      (num2 (expval->num val2)))
                  (num-val (- num1 num2))
                  )
                )
              )
    ; true only if exp1 is number 0
    (zero?-exp (exp1)
               (let ((val (value-of-exp exp1 env)))
                 (let ((num (expval->num val)))
                   (if (zero? num)
                       (bool-val #t)
                       (bool-val #f)
                       )
                   )
                 )
               )
    (if-exp (exp1 exp2 exp3)
            (let ((val1 (value-of-exp exp1 env)))
              (if (expval->bool val1)
                  (value-of-exp exp2 env)
                  (value-of-exp exp3 env)
                  )
              )
            )
    (var-exp (var)
             (apply-env env var)
             )
    (let-exp (var exp1 body)
             (let ((val1 (value-of-exp exp1 env)))
               (value-of-exp body (extend-env var val1 env))
               )
             )
    (proc-exp (var body)
              (proc-val (procedure var body env))
              )
    (call-exp (rator rand)
              (let ((rator-val (value-of-exp rator env)) (rand-val (value-of-exp rand env)))
                (let ((proc1 (expval->proc rator-val)))
                  (apply-procedure proc1 rand-val)
                  )
                )
              )
    (else 42)
    )
  )