#lang eopl

(require racket/lazy-require "value.rkt" "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env
                     build-circular-extend-env-rec-mul-vec
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

; get value of a list of exp
(define (value-of-exps exps env)
  (map (lambda (exp) (value-of-exp exp env)) exps)
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
             (let ((val (value-of-exp exp1 env)))
               (value-of-exp body (extend-env var val env))
               )
             )
    (letrec-exp (p-names b-vars-list p-bodies body)
                (let ((new-env (build-circular-extend-env-rec-mul-vec p-names b-vars-list p-bodies env)))
                  (value-of-exp body new-env)
                  )
                )
    (proc-exp (first-var rest-vars body)
              (proc-val (procedure (cons first-var rest-vars) body env))
              )
    (call-exp (rator rands)
              (let ((rator-val (value-of-exp rator env)) (rand-vals (value-of-exps rands env)))
                (let ((proc1 (expval->proc rator-val)))
                  (apply-procedure proc1 rand-vals)
                  )
                )
              )
    (else 42)
    )
  )
