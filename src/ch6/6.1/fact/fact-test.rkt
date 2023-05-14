#lang eopl

(require rackunit)
(require racket)

(provide (all-defined-out))

(define (test-fact fact)
    (check-equal? (fact 0) 1 "fact 0 = 1")
    (check-equal? (fact 1) 1 "fact 1 = 1")
    (check-equal? (fact 2) 2 "fact 2 = 2")
    (check-equal? (fact 3) 6 "fact 3 = 6")
    (check-equal? (fact 4) 24 "fact 4 = 24")
    (check-equal? (fact 5) 120 "fact 5 = 120")
)
