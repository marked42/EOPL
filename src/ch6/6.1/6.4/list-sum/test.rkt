#lang eopl

(require rackunit)

(provide (all-defined-out))

(define (test-list-sum list-sum)
  (check-equal? (list-sum '()) 0 "sum of empty list is 0")
  (check-equal? (list-sum (list 1)) 1 "sum of list of length 1")
  (check-equal? (list-sum '(1 2)) 3 "sum of list of length 2")
  (check-equal? (list-sum '(1 2 3)) 6 "sum of list of length 3")
  )
