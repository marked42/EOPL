#lang eopl

(require rackunit "main.rkt")

(check-equal? (filter-in number? '(a 2 (1 3) b 7)) '(2 7) "filter in numbers")
(check-equal? (filter-in symbol? '(a (b c) 17 foo)) '(a foo) "filter in symbols")
