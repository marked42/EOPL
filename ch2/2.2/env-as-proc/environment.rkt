#lang eopl

(provide (all-defined-out))

(define (empty-env)
  (lambda (var)
    (report-no-binding-found var)
    )
  )

(define (extend-env var val env)
  (lambda (search-var)
    (if (eqv? var search-var)
        val
        (apply-env env search-var)
        )
    )
  )

(define (apply-env env search-var)
  (env search-var)
  )

(define (report-no-binding-found search-var)
  (eopl:error 'apply-env "No binding for ~s" search-var)
  )