#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../../../base/basic.rkt" (identifier?)]
 ["expression.rkt" (expression?)]
 ["interpreter.rkt" (value-of-exp)]
 ["environment.rkt" (extend-env* environment?)]
 )

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (vars (list-of identifier?))
   (body expression?)
   (saved-env environment?)
   )
  )

(define (apply-procedure proc1 args)
  (cases proc proc1
    (procedure (vars body saved-env)
               (value-of-exp body (extend-env* vars args saved-env))
               )
    )
  )

(define (create-procedure vars args saved-env)
  (procedure vars args saved-env)
  )
