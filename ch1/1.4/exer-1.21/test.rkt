#lang eopl

(require rackunit "main.rkt")

(check-equal? (product '(a b c) '(x y)) '((a x) (a y) (b x) (b y) (c x) (c y)) "cartesian product")
