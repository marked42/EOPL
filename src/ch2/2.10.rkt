#lang eopl

(require "2.5.rkt")

(define (extend-env* vars vals env)
  (if (null? vars)
      env
      (let ((var (car vars)) (rest-vars (cdr vars)) (val (car vals)) (rest-vals (cdr vals)))
        (extend-env* rest-vars rest-vals (extend-env var val env))
        )
      )
  )
