#lang eopl

(require rackunit "../bintree.rkt")

(check-equal? (interior-node 'red (leaf 1) (leaf 2)) '(red 1 2) "build binary tree")
