#lang eopl

(require racket/list)

(provide (all-defined-out))

(define (empty-env)
  (list
   (list
    (lambda (var)
      (report-no-binding-found var)
      )
    (lambda () #t)
    (lambda (var) #f)
    )
   )
  )

(define (extend-env var val env)
  (cons
   (list
    (lambda (search-var)
      (if (eqv? var search-var)
          val
          (apply-env env search-var)
          )
      )
    (lambda () #f)
    (lambda (search-var)
      (if (eqv? var search-var)
          #t
          (has-binding? env search-var)
          )
      )
    )
   env
   )
  )

(define (apply-env env search-var)
  ((first (car env)) search-var)
  )

(define (empty-env? env)
  ((second (car env)))
  )

(define (has-binding? env search-var)
  ((third (car env)) search-var)
  )

(define (report-no-binding-found search-var)
  (eopl:error 'apply-env "No binding for ~s" search-var)
  )
