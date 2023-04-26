#lang eopl

(require racket/lazy-require racket/list)
(lazy-require
 ["../shared/expression.rkt" (expression?)]
 ["../shared/basic.rkt" (identifier?)]
 ["../shared/store.rkt" (vals->refs)]
 ["environment.rkt" (environment? extend-mul-env)]
 ["continuation.rkt" (cont? apply-cont)]
 )

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (vars (list-of identifier?))
   (body expression?)
   (saved-env environment?)
   )
  (cont-procedure
    (cont cont?)
   )
  )

(define (apply-procedure/k value-of/k proc1 args saved-cont)
  (cases proc proc1
    (procedure (vars body saved-env)
               ; create new ref under implicit refs, aka call-by-value
               (value-of/k body (extend-mul-env vars (vals->refs args) saved-env) saved-cont)
               )
    (cont-procedure (cont)
                    (if (not (= (length args) 1))
                      (eopl:error "cont-procedure accept only single argument, get ~s " args)
                      (apply-cont cont (car args))
                    )
                    )
    )
  )
