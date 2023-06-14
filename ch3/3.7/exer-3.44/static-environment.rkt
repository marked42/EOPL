#lang eopl

(provide (all-defined-out))

(require "expression.rkt")
(define (empty-env) '())

(define (init-senv)
  (extend-senv-normal 'i
                      (extend-senv-normal 'v
                                          (extend-senv-normal 'x (empty-env))
                                          )
                      )
  )

(define (extend-senv var val senv)
  (cons (cons var val) senv)
  )

(define (extend-senv-normal var senv)
  (extend-senv var #f senv)
  )

(define (apply-senv senv var)
  (let loop ([senv senv] [depth 0])
    (if (null? senv)
        (report-unbound-var var)
        (let ([saved-var (caar senv)] [saved-val (cdar senv)])
          (if (eqv? saved-var var)
              (list depth saved-val)
              (loop (cdr senv) (+ depth 1))
              )
          )
        )
    )
  )

(define (report-unbound-var var)
  (eopl:error 'apply-senv "No binding for ~s" var)
  )
