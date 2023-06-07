#lang eopl

(provide (all-defined-out))

(define (empty-env) '())

(define (init-senv)
    (extend-senv 'i
        (extend-senv 'v
            (extend-senv 'x (empty-env))
        )
    )
)

(define (extend-senv var senv)
    (cons var senv)
)

(define (apply-senv senv var)
    (cond
        [(null? senv) (report-unbound-var var)]
        [(eqv? (car senv) var) 0]
        [else (+ 1 (apply-senv (cdr senv) var))]
    )
)

(define (report-unbound-var var)
  (eopl:error 'apply-senv "No binding for ~s" var)
)
