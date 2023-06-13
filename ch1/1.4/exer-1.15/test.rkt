#lang eopl

(require rackunit "main.rkt")

(check-equal? (duple 2 3) '(3 3) "should return (1 1 1)")
(check-equal? (duple 4 '(ha ha)) '((ha ha) (ha ha) (ha ha) (ha ha)) "should return ((ha ha) (ha ha) (ha ha) (ha ha))")
(check-equal? (duple 0 '(blah)) '() "should return empty list")
