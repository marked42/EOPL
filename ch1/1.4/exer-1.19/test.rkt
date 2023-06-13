#lang eopl

(require rackunit "main.rkt")

(check-equal? (list-set '(a b c d) 2 '(1 2)) '(a b (1 2) d) "set 2nd element to (1 2)")
(check-equal? (list-ref (list-set '(a b c d) 3 '(1 5 10)) 3) '(1 5 10) "set 3rd element to (1 5 10)")
