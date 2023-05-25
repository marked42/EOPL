#lang eopl

(require racket/lazy-require "../cps-lang/expression.rkt")
(lazy-require
 ["../transformer-book/transformer.rkt" (create-cps-of-program)]
 )

(provide (all-defined-out))

(define (make-send-to-cont k-exp simple-exp)
  (cases simple-expression k-exp
    (cps-proc-exp (vars body)
                  (if (= (length vars) 1)
                      (cps-let-exp vars (list simple-exp) body)
                      (cps-call-exp k-exp (list simple-exp))
                      )
                  )
    (else (cps-call-exp k-exp (list simple-exp)))
    )
  )

(define cps-of-program (create-cps-of-program make-send-to-cont))
