#lang eopl

(require rackunit "../bintree.rkt" "main.rkt")

(check-equal? (double-tree (interior-node 'red (leaf 1) (leaf 2))) '(red 2 4) "double binary tree")
