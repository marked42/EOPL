#lang eopl

(require "value.rkt")
(require "basic.rkt")
(provide (all-defined-out))

(define (empty-env) '())

; define single var
(define (extend-env var val env)
  (cons (cons var val) env)
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
  (cond
    ((< search-var 0) (report-no-binding-found search-var))
    ((= search-var 0) (cdar env))
    (else (apply-env (cdr env) (- search-var 1)))
    )
  )

(define (environment? env) (list? env))
