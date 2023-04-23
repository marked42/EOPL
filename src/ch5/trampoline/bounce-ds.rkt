#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../shared/value.rkt" (expval?)]
 ["../shared/procedure.rkt" (proc?)]
 ["continuation.rkt" (cont?)]
 )

(provide (all-defined-out))

(define-datatype bounce bounce?
  (a-bounce (apply-procedure/k procedure?) (value-of/k procedure?) (proc1 proc?) (args (list-of expval?)) (saved-cont cont?))
  )

(define (create-bounced-apply-procedure/k apply-procedure/k)
  (lambda (value-of/k proc1 args saved-cont)
    (a-bounce apply-procedure/k value-of/k proc1 args saved-cont)
    )
  )

(define (is-bounce val)
  (procedure? val)
  )

(define (apply-bounce bc)
  (cases bounce bc
    (a-bounce (apply-procedure/k value-of/k proc1 args saved-cont)
              (apply-procedure/k value-of/k proc1 args saved-cont)
              )
    )
  )
