#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../../../base/basic.rkt" (identifier?)]
 ["expression.rkt" (tfexp?)]
 ["interpreter.rkt" (value-of/k)]
 ["environment.rkt" (extend-env* environment?)]
 )

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (vars (list-of identifier?))
   (body tfexp?)
   (saved-env environment?)
   )
  )

(define (apply-procedure proc1 args cont)
  (cases proc proc1
    (procedure (vars body saved-env)
               (value-of/k body (extend-env* vars args saved-env) cont)
               )
    )
  )

(define (create-procedure vars args saved-env)
  (procedure vars args saved-env)
  )
