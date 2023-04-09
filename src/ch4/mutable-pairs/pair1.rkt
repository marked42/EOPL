#lang eopl

(require racket/lazy-require)
(lazy-require
    ["store.rkt" (reference? newref deref setref)]
)

(provide (all-defined-out))

(define-datatype mut-pair mut-pair?
    (a-pair
        (left-loc reference?)
        (right-loc reference?)
    )
)

(define (make-pair left right)
    (a-pair (newref left) (newref right))
)

(define (left pair)
    (cases mut-pair pair
        (a-pair (left-loc right-loc) (deref left-loc))
    )
)

(define (right pair)
    (cases mut-pair pair
        (a-pair (left-loc right-loc) (deref right-loc))
    )
)

(define (setleft pair val)
    (cases mut-pair pair
        (a-pair (left-loc right-loc) (setref left-loc val))
    )
)

(define (setright pair val)
    (cases mut-pair pair
        (a-pair (left-loc right-loc) (setref right-loc val))
    )
)
