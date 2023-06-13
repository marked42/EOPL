#lang eopl

(require rackunit "main.rkt")

(check-equal? (down '(1 2 3)) '((1) (2) (3)) "should wrap top element with parenthesis")
(check-equal? (down '((a) (fine) (idea))) '(((a)) ((fine)) ((idea))) "should wrap top element with parenthesis")
(check-equal? (down '(a (more (complicated)) object)) '((a) ((more (complicated))) (object)) "should wrap top element with parenthesis")
