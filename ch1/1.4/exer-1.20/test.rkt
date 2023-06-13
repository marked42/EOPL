#lang eopl

(require rackunit "main.rkt")

(check-equal? (count-occurrences 'x '((f x) y (((x z) x)))) 3 "count x")
(check-equal? (count-occurrences 'x '((f x) y (((x z) () x)))) 3 "count x")
(check-equal? (count-occurrences 'w '((f x) y (((x z) () x)))) 0 "count w")
