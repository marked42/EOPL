#lang eopl

(provide (all-defined-out))

(define (empty-env)
  (list
   (cons
    (lambda (var)
      (report-no-binding-found var)
      )
    (lambda () #t)
    )
   )
  )

(define (extend-env var val env)
  (cons
   (cons
    (lambda (search-var)
      (if (eqv? var search-var)
          val
          (apply-env env search-var)
          )
      )
    (lambda () #f)
    )
   env
   )
  )

(define (apply-env env search-var)
  ((caar env) search-var)
  )

(define (empty-env? env)
  ; get cdr of first pair, it's a pair not a list, using cadar is wrong
  ; (cadr ((apply-env . empty-env?) ...))
  ; (cadar ((apply-env empty-env? ...) ...))
  ((cdar env))
  )

(define (report-no-binding-found search-var)
  (eopl:error 'apply-env "No binding for ~s" search-var)
  )
