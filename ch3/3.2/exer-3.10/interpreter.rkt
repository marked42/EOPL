#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env
                     )]
 ["value.rkt" (num-val
               expval->num
               bool-val
               expval->bool
               ; new stuff
               null-val
               cell-val
               cell-val->first
               cell-val->second
               null-val?
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
    (cons-exp (exp1 exp2)
              (let ([val1 (value-of-exp exp1 env)] [val2 (value-of-exp exp2 env)])
                (cell-val val1 val2)
                )
              )
    (car-exp (exp1)
             (let ([val1 (value-of-exp exp1 env)])
               (cell-val->first val1)
               )
             )
    (cdr-exp (exp1)
             (let ([val1 (value-of-exp exp1 env)])
               (cell-val->second val1)
               )
             )
    (emptylist-exp () (null-val))
    (null?-exp (exp1)
               (let ([val1 (value-of-exp exp1 env)])
                 (bool-val (null-val? val1))
                 )
               )
    ; new stuff
    (list-exp (exps)
              (let ([vals (value-of-exps exps env)])
                (let build-list ([vals vals])
                  (if (null? vals)
                      (null-val)
                      (let ((first (car vals)) (rest (cdr vals)))
                        (cell-val first (build-list rest))
                        )
                      )
                  )
                )
              )
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )

(define (value-of-exps exps env)
  (map (lambda (exp) (value-of-exp exp env)) exps)
  )
