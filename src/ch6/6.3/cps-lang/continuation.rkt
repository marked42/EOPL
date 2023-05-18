#lang eopl

(provide (all-defined-out))

(define-datatype continuation cont?
  (end-cont)
  )

(define (apply-cont cont val)
  (cases continuation cont
    (end-cont () val)
    )
  )
