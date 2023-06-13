#lang eopl

(require rackunit "main.rkt")

(check-equal? (swapper 'a 'd '(a b c d)) '(d b c a) "swap a and d")
(check-equal? (swapper 'a 'd '(a d () c d)) '(d a () c a) "swap a and d")
(check-equal? (swapper 'x 'y '((x) y (z (x)))) '((y) x (z (y))) "swap x and y deeply")
