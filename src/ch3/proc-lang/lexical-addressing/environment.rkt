#lang eopl

(require "value.rkt")
(require "basic.rkt")
(provide (all-defined-out))

(define (empty-env) '())

; define single var
(define (extend-env val env)
  (let ((vec (make-vector 1)))
    (vector-set! vec 0 val)
    (cons vec env)
    )
  )

(define (extend-env-vec vec env)
  (cons vec env)
  )

(define (init-env)
  (extend-env (num-val 1)
              (extend-env (num-val 5)
                          (extend-env (num-val 10)
                                      (empty-env)
                                      )
                          )
              )
  )

(define (apply-env env search-var)
  (cond
    ((< search-var 0) (report-no-binding-found search-var))
    ((= search-var 0) (vector-ref (car env) 0))
    (else (apply-env (cdr env) (- search-var 1)))
    )
  )

(define (environment? env) (list? env))
