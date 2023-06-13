#lang eopl

(require rackunit "../bintree.rkt" "main.rkt")

(define tree
  (interior-node 'red
                 (interior-node 'bar
                                (leaf 26)
                                (leaf 12))
                 (interior-node 'red
                                (leaf 11)
                                (interior-node 'quux
                                               (leaf 117)
                                               (leaf 14)))))
(define marked-tree
  (list 'red
        (list 'bar 1 1)
        (list 'red 2 (list 'quux 2 2))
        )
  )

(check-equal? (mark-leaves-with-red-depth tree) marked-tree "mark tree")
