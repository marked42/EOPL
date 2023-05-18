#lang eopl

(require rackunit)

(provide (all-defined-out))

(define (test-remove-first remove-first)
  (check-equal? '() (remove-first 1 '()) "remove from empty list")
  (check-equal? '(2 3) (remove-first 1 '(1 2 3)) "remove existing element in list")
  (check-equal? '(1 3) (remove-first 2 '(1 2 3)) "remove existing element in list")
  (check-equal? '(1 2) (remove-first 3 '(1 2 3)) "remove existing element in list")
  (check-equal? '(1 2 3) (remove-first 4 '(1 2 3)) "remove non-existing element in list")
  )
