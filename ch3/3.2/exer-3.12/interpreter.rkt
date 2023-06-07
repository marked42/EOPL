#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt" "value.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env
                     )]
 )

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
    (const-exp (num) (num-val num))
    (var-exp (var) (apply-env env var))
    (diff-exp (exp1 exp2)
              (let ([val1 (value-of-exp exp1 env)]
                    [val2 (value-of-exp exp2 env)])
                (let ((num1 (expval->num val1))
                      (num2 (expval->num val2)))
                  (num-val (- num1 num2))
                  )
                )
              )
    (zero?-exp (exp1)
               (let ([val (value-of-exp exp1 env)])
                 (let ([num (expval->num val)])
                   (if (zero? num)
                       (bool-val #t)
                       (bool-val #f)
                       )
                   )
                 )
               )
    (if-exp (exp1 exp2 exp3)
            (let ([val1 (value-of-exp exp1 env)])
              (if (expval->bool val1)
                  (value-of-exp exp2 env)
                  (value-of-exp exp3 env)
                  )
              )
            )
    (let-exp (var exp1 body)
             (let ([val (value-of-exp exp1 env)])
               (value-of-exp body (extend-env var val env))
               )
             )
    ; new stuff
    (cond-exp (cond-exps act-exps)
              (let return-first-true-cond ([conditions cond-exps] [actions act-exps])
                (if (null? conditions)
                    (eopl:error 'cond-exp "No true cond for exp ~s" exp)
                    (let ([first-condition (car conditions)])
                      ; must require value.rkt synchronously for cases to work
                      (cases expval (value-of-exp first-condition env)
                        (bool-val (bool)
                                  (if bool
                                      (value-of-exp (car actions) env)
                                      (return-first-true-cond (cdr conditions) (cdr actions))
                                      )
                                  )
                        (else (eopl:error 'cond-exp "invalid predicate " exp))
                        )
                      )
                    )
                )
              )
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )
