#lang eopl

(require rackunit "main.rkt")

(check-equal? (merge '(1 4) '(1 2 8)) '(1 1 2 4 8) "merge")
(check-equal? (merge '(35 62 81 90 91) '(3 83 85 90)) '(3 35 62 81 83 85 90 90 91) "merge")
