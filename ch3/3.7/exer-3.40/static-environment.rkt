#lang eopl

(provide (all-defined-out))

(define (empty-env) '())

(define (init-senv)
  (extend-senv-normal 'i
               (extend-senv-normal 'v
                            (extend-senv-normal 'x (empty-env))
                            )
               )
  )

(define (extend-senv type var senv)
  (cons (list type var) senv)
  )

(define (extend-senv-normal var senv)
  (extend-senv 'normal var senv)
)

(define (extend-senv-letrec var senv)
  (extend-senv 'letrec var senv)
)

(define (apply-senv senv var)
  (cond
    [(null? senv) (report-unbound-var var)]
    [(eqv? (cadar senv) var) 0]
    [else (+ 1 (apply-senv (cdr senv) var))]
    )
  )

(define (report-unbound-var var)
  (eopl:error 'apply-senv "No binding for ~s" var)
  )
