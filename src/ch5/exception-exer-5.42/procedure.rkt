#lang eopl

(require racket/lazy-require racket/list)
(lazy-require
 ["../shared/expression.rkt" (expression?)]
 ["../shared/basic.rkt" (identifier?)]
 ["../shared/store.rkt" (vals->refs)]
 ["environment.rkt" (environment? extend-mul-env)]
 )

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (vars (list-of identifier?))
   (body expression?)
   (saved-env environment?)
   )
  )

(define (proc->procedure proc1)
  (cases proc proc1
    (procedure (vars body saved-env)
               (list vars body saved-env)
               )
    (else (eopl:error 'proc->procedure "invalid proc ~s " proc1))
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
