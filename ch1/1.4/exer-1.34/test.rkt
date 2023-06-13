#lang eopl

(require rackunit "../bintree.rkt" "main.rkt")

(define path-tree
  '(14 (7 () (12 () ()))
       (26 (20 (17 () ())
               ())
           (31 () ()))))

(check-equal? (path 17 path-tree) '(right left left) "return path")
