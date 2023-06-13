#lang eopl

(require rackunit "main.rkt")

(check-equal? (sort '(8 2 5 2 3)) '(2 2 3 5 8) "sort in ascending order")
