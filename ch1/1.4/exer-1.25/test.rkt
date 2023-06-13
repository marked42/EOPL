#lang eopl

(require rackunit "main.rkt")

(check-equal? (exists? number? '(a b c 3 e)) #t "should be true")
(check-equal? (exists? number? '(a b c d e)) #f "should be false")
