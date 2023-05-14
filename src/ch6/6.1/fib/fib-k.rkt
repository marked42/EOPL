#lang eopl

(require "test.rkt")

(define (fib n)
    (fib/k n (end-cont))
)

(define (fib/k n saved-cont)
    (if (< n 2)
        (apply-cont saved-cont 1)
        (fib/k (- n 1) (fib1-cont (- n 2) saved-cont))
    )
)

(define (fib1-cont n2 saved-cont)
    (lambda (val)
        (fib/k n2 (fib2-cont val saved-cont))
    )
)

(define (fib2-cont n1 saved-cont)
    (lambda (n2)
        (apply-cont saved-cont (+ n1 n2))
    )
)

(define (end-cont)
    (lambda (val) val)
)

(define (apply-cont cont val)
    (cont val)
)

(test-fib fib)
