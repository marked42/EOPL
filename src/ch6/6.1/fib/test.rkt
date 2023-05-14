#lang eopl

(require rackunit)
(require racket)

(provide (all-defined-out))

(define (test-fib fib)
    (check-equal? (fib 0) 1 "fib 0 = 1")
    (check-equal? (fib 1) 1 "fib 1 = 1")
    (check-equal? (fib 2) 2 "fib 2 = 2")
    (check-equal? (fib 3) 3 "fib 3 = 3")
    (check-equal? (fib 4) 5 "fib 4 = 5")
    (check-equal? (fib 5) 8 "fib 5 = 8")
)
