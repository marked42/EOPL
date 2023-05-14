#lang eopl

(require "fact-test.rkt")

(define (fact n)
    (if (zero? n) 1 (* n (fact (- n 1))))
)

(test-fact fact)
