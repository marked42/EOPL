#lang eopl

(define (empty-env) '())

(define (extend-env var val env)
  (extend-env* (list var) (list val) env)
  )

(define (extend-env* vars vals env)
  (cons (cons vars vals) env)
  )

; TODO: search sequentially
; (define (apply-env env var)
;   )
