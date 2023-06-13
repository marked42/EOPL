#lang eopl

(require rackunit "main.rkt")

(check-equal? (sort/predicate < '(8 2 5 2 3)) '(2 2 3 5 8) "sort in ascending order")
(check-equal? (sort/predicate > '(8 2 5 2 3)) '(8 5 3 2 2) "sort in descending order")
