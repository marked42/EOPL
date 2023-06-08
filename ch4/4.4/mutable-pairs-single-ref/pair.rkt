#lang eopl

(require racket/lazy-require)
(lazy-require
 ["store.rkt" (reference? newref deref setref!)]
 )

(provide (all-defined-out))

(define-datatype mutpair mutpair?
  (a-pair (ref reference?))
  )

(define (make-pair val1 val2)
  (let ([ref (newref val1)])
    (newref val2)
    (a-pair ref)
    )
  )

(define (left pair)
  (cases mutpair pair
    (a-pair (ref) (deref ref))
    )
  )

(define (right pair)
  (cases mutpair pair
    (a-pair (ref) (deref (+ 1 ref)))
    )
  )

(define (set-left! pair val)
  (cases mutpair pair
    (a-pair (ref) (setref! ref val))
    )
  )

(define (set-right! pair val)
  (cases mutpair pair
    (a-pair (ref) (setref! (+ 1 ref) val))
    )
  )
