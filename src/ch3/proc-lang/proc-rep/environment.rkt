#lang eopl

(require "expression.rkt")
(require "value.rkt")
(require "basic.rkt")
(provide (all-defined-out))

(define (empty-env) '())

; define single var
(define (extend-env var val env)
  (cons (cons var val) env)
  )

; define multiple vars
(define (extend-mul-env vars vals env)
  (if (null? vars)
      env
      (let ((first-var (car vars)) (first-val (car vals)))
        (extend-env
         first-var
         first-val
         (extend-mul-env (cdr vars) (cdr vals) env))
        )
      )
  )

(define (init-env)
  (extend-env 'i (num-val 1)
              (extend-env 'v (num-val 5)
                          (extend-env 'x (num-val 10)
                                      (empty-env)
                                      )
                          )
              )
  )

(define (apply-env env search-var)
  (if (null? env)
      (report-no-binding-found search-var)
      (let ((saved-var (caar env)) (saved-val (cdar env)) (saved-env (cdr env)))
        (if (eqv? saved-var search-var)
            saved-val
            (apply-env saved-env search-var)
            )
        )
      )
  )
