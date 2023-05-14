#lang eopl

(require "test.rkt")

(define (fib n)
    (fib/k n (lambda (val) val))
)

(define (fib/k n cont)
    (if (< n 2)
        (cont 1)
        (fib/k (- n 1) (lambda (n1)
            (fib/k (- n 2) (lambda (n2)
                (cont (+ n1 n2))
            ))
        ))
    )
)

(test-fib fib)
