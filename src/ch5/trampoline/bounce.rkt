#lang eopl

(provide (all-defined-out))

(define (create-bounced-apply-procedure/k apply-procedure/k)
  (lambda (value-of/k proc1 args saved-cont)
    (lambda ()
      (apply-procedure/k value-of/k proc1 args saved-cont)
      )
    )
  )

(define (is-bounce val)
  (procedure? val)
  )

(define (apply-bounce bounce)
  (bounce)
  )
