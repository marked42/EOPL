#lang eopl

(require racket/lazy-require racket/list)
(lazy-require
 ["expression.rkt" (expression?)]
 ["basic.rkt" (identifier?)]
 ["environment.rkt" (environment?)]
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
               ; create new ref under implicit refs, aka call-by-value
               (list vars body saved-env)
               )
    )
  )
