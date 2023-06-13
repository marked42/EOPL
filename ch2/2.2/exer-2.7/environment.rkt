#lang eopl

(provide (all-defined-out))

(define (empty-env) (list 'empty-env))

(define (extend-env var val env)
  (list 'extend-env var val env)
  )

(define (apply-env env search-var)
  (let ([whole-env env])
    (let loop ([env env])
      (cond
        [(eqv? (car env) 'empty-env) (report-no-binding-found search-var whole-env)]
        [(eqv? (car env) 'extend-env)
         (let ([saved-var (cadr env)] [saved-val (caddr env)] [saved-env (cadddr env)])
           (if (eqv? search-var saved-var)
               saved-val
               (loop saved-env)
               )
           )
         ]
        [else (report-invalid-env env)]
        )
      )
    )
  )

(define (report-no-binding-found search-var whole-env)
  (eopl:error 'apply-env "No binding for ~s in env " search-var whole-env)
  )


(define (report-invalid-env env)
  (eopl:error 'apply-env "Bad environment: ~s" env)
  )
