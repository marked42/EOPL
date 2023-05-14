#lang eopl

(require "fact-test.rkt")

(define n 'uninitialized)
(define val 'uninitialized)
(define cont 'uninitialized)

(define (fact n1)
    (set! n n1)
    (set! val 1)
    (set! cont (end-cont))
    (fact/k)
)

(define (fact/k)
    (if (zero? n)
        (apply-cont cont 1)
        (set! n (- n 1))
        (fact/k (fact-cont n cont))
    )
)

(define (end-cont)
    (lambda (val) val)
)

(define (fact-cont n)
    (lambda (val)
        (set! val (* n val))
        (set! cont saved-cont)
        (apply-cont)
    )
)

(define (apply-cont cont val)
    (cont val)
)

(test-fact fact)
