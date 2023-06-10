#lang eopl

(require racket/lazy-require racket/list "parser.rkt" "expression.rkt")
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
               cell-val?
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
    (unpack-exp (vars exp1 body)
                (let ([val1 (value-of-exp exp1 env)])
                  (value-of-exp body (extend-env-unpack vars val1 env))
                )
    )
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )

(define (extend-env-unpack vars val env)
  (cond
    ((and (null? vars) (null-val? val)) env)
    ((and (pair? vars) (cell-val? val))
     (let ((first-var (car vars)) (first-val (cell-val->first val)))
       ; define vars from left to right
       (let ((new-env (extend-env first-var first-val env)))
         (extend-env-unpack (cdr vars) (cell-val->second val) new-env)
         )
       )
     )
    (else (report-unpack-unequal-vars-list-count val))
    )
  )

(define (report-unpack-unequal-vars-list-count exp)
  (eopl:error 'unpack-exp "Unequal vars and list count ~s" exp)
  )
