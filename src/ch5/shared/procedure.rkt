#lang eopl

(require racket/lazy-require racket/list)
(lazy-require
 ["expression.rkt" (expression?)]
 ["basic.rkt" (identifier?)]
 ["environment.rkt" (environment? extend-mul-env)]
 ["store.rkt" (vals->refs)]
 )

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (vars (list-of identifier?))
   (body expression?)
   (saved-env environment?)
   )
  )

(define (apply-procedure/k value-of/k proc1 args saved-cont)
  (cases proc proc1
    (procedure (vars body saved-env)
               ; create new ref under implicit refs, aka call-by-value
               (value-of/k body (extend-mul-env vars (vals->refs args) saved-env) saved-cont)
               )
    )
  )
