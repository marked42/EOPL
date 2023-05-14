#lang eopl

(require "fact-test.rkt")

(define (fact n)
    (fact/k n (end-cont))
)

(define (fact/k n cont)
    (if (zero? n)
        (apply-cont cont 1)
        (fact/k (- n 1) (fact-cont n cont))
    )
)

(define (end-cont)
    (lambda (val) val)
)

(define (fact-cont n saved-cont)
    (lambda (val)
        (apply-cont saved-cont (* n val))
    )
)

(define (apply-cont cont val)
    (cont val)
)

(test-fact fact)
