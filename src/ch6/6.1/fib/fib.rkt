#lang eopl

(require "test.rkt")

(define (fib n)
    (if (< n 2)
        1
        (+ (fib (- n 1)) (fib (- n 2)))
    )
)

(test-fib fib)
