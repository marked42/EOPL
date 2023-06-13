#lang eopl

(require rackunit "main.rkt")

(check-equal? (number-elements '(v0 v1 v2)) '((0 v0) (1 v1) (2 v2)) "number list elements")
(check-equal? (number-elements-v2 '(v0 v1 v2)) '((0 v0) (1 v1) (2 v2)) "number list elements")
