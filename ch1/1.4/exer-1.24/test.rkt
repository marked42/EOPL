#lang eopl

(require rackunit "main.rkt")

(check-equal? (every? number? '(a b c 3 e)) #f "should be false")
(check-equal? (every? number? '(1 2 3 5 4)) #t "should be true")
