#lang eopl

(require "basic.rkt")
(require racket/list)
(provide (all-defined-out))

(define (empty-senv) '())

; each env can contain multiple values
; variable index if a pair of integer index
(define (extend-senv vars env)
  (cons vars env)
  )

(define (init-senv)
  (extend-senv '(i)
               (extend-senv '(v)
                            (extend-senv '(x) (empty-senv))
                            )
               )
  )

(define (apply-senv env search-var)
  (apply-env-helper env search-var 0)
  )

(define (apply-env-helper env search-var env-offset)
  (if (null? env)
    (report-no-binding-found search-var)
    (let ((vars (car env)))
      (let ((index (index-of vars search-var)))
        (if index
          (cons env-offset index)
          (apply-env-helper (cdr env) search-var (+ 1 env-offset))
        )
      )
    )
  )
)
