#lang eopl

(require rackunit "main.rkt")

(check-equal? (invert '((a 1) (a 2) (1 b) (2 b))) '((1 a) (2 a) (b 1) (b 2)) "should invert elements")
