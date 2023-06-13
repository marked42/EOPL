#lang eopl

(require rackunit "main.rkt")

(check-equal? (list-index number? '(a 2 (1 3) b 7)) 1 "first number at 1")
(check-equal? (list-index symbol? '(a (b c) 17 foo)) 0 "first symbol at 0")
(check-equal? (list-index symbol? '(1 2 (a b) 3)) #f "no symbols found")
