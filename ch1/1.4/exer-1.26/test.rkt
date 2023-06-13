#lang eopl

(require rackunit "main.rkt")

(check-equal? (up '((1 2) (3 4))) '(1 2 3 4) "up")
(check-equal? (up '((x (y)) z)) '(x (y) z) "up")
