#lang eopl

(require "basic.rkt")
(provide (all-defined-out))

(define (empty-senv) '())

(define (extend-senv var env)
  (cons var env)
  )

(define (init-senv)
  (extend-senv 'i
               (extend-senv 'v
                            (extend-senv 'x (empty-senv))
                            )
               )
  )

(define (apply-senv env search-var)
  (if (null? env)
      (report-no-binding-found search-var)
      (let ((var (car env)))
        (if (eqv? var search-var)
            0
            (+ 1 (apply-senv (cdr env) search-var))
            )
        )
      )
  )
