#lang eopl

(provide (all-defined-out))

(define (pair-of pred1 pred2)
  (lambda (val) (and (pred1 (car val)) (pred2 (cdr val))))
  )
