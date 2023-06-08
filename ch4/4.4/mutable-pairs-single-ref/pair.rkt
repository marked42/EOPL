#lang eopl

(require racket/lazy-require)
(lazy-require
 ["store.rkt" (reference? newref deref setref!)]
 )

(provide (all-defined-out))

(define-datatype mutpair mutpair?
  (a-pair (left-loc reference?) (right-loc reference?))
  )

(define (make-pair val1 val2)
  (a-pair (newref val1) (newref val2))
  )

(define (left pair)
  (cases mutpair pair
    (a-pair (left-loc right-loc) (deref left-loc))
    )
  )

(define (right pair)
  (cases mutpair pair
    (a-pair (left-loc right-loc) (deref right-loc))
    )
  )

(define (set-left! pair val)
  (cases mutpair pair
    (a-pair (left-loc right-loc) (setref! left-loc val))
    )
  )

(define (set-right! pair val)
  (cases mutpair pair
    (a-pair (left-loc right-loc) (setref! right-loc val))
    )
  )
