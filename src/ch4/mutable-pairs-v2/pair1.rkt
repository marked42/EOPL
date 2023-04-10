#lang eopl

(require racket/lazy-require)
(lazy-require
 ["store.rkt" (reference? newref deref setref)]
 )

(provide (all-defined-out))

(define-datatype mut-pair mut-pair?
  (a-pair (left-loc reference?))
  )

(define (make-pair left right)
  (let ((left-loc (newref left)))
    (newref right)
    (a-pair left-loc)
    )
  )

(define (get-right-loc left-loc)
  (+ 1 left-loc)
  )

(define (left pair)
  (cases mut-pair pair
    (a-pair (left-loc) (deref left-loc))
    )
  )

(define (right pair)
  (cases mut-pair pair
    (a-pair (left-loc) (deref (get-right-loc left-loc)))
    )
  )

(define (setleft pair val)
  (cases mut-pair pair
    (a-pair (left-loc) (setref left-loc val))
    )
  )

(define (setright pair val)
  (cases mut-pair pair
    (a-pair (left-loc) (setref (get-right-loc left-loc) val))
    )
  )
