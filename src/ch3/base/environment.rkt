#lang eopl

(require racket/lazy-require "basic.rkt")
(lazy-require
 ["value.rkt" (num-val expval?)]
 )
(provide (all-defined-out))

(define-datatype environment environment?
  (empty-env)
  (extend-env
   (var identifier?)
   (val expval?)
   (env environment?)
   )
  )

; use a vec to build circular refs to avoid create same proc-val multiple times

(define (init-env)
  (extend-env 'i (num-val 1)
              (extend-env 'v (num-val 5)
                          (extend-env 'x (num-val 10)
                                      (empty-env)
                                      )
                          )
              )
  )

(define (apply-env env search-var)
  (cases environment env
    (extend-env (var val saved-env)
                (if (eqv? search-var var)
                    val
                    (apply-env saved-env search-var)
                    )
                )
    (else (report-no-binding-found search-var))
    )
  )
