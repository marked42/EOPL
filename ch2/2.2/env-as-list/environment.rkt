#lang eopl

(provide (all-defined-out))

(define (empty-env) (list 'empty-env))

(define (extend-env var val env)
  (list 'extend-env var val env)
  )

(define (apply-env env search-var)
  (cond
    [(eqv? (car env) 'empty-env) (report-no-binding-found search-var)]
    [(eqv? (car env) 'extend-env)
     (let ([saved-var (cadr env)] [saved-val (caddr env)] [saved-env (cadddr env)])
       (if (eqv? search-var saved-var)
           saved-val
           (apply-env saved-env search-var)
           )
       )
     ]
    [else (report-invalid-env env)]
    )
  )

(define (report-no-binding-found search-var)
  (eopl:error 'apply-env "No binding for ~s" search-var)
  )


(define (report-invalid-env env)
  (eopl:error 'apply-env "Bad environment: ~s" env)
  )
