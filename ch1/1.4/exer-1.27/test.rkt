#lang eopl

(require rackunit "main.rkt")

(check-equal? (flatten '(a b c)) '(a b c) "flatten")
(check-equal? (flatten '((a) () (b ()) () (c))) '(a b c) "flatten")
(check-equal? (flatten '((a b) c (((d) e)))) '(a b c d e) "flatten")
(check-equal? (flatten '(a b (() (c)))) '(a b c) "flatten")
