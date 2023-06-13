#lang eopl

(require "../bintree.rkt")
(provide (all-defined-out))

(define (double-tree tree)
  (if (leaf? tree)
      (leaf (* 2 (contents-of tree)))
      (let ((content (contents-of tree)) (left (lson tree)) (right (rson tree)))
        (interior-node
         content
         (double-tree (leaf left))
         (double-tree (leaf right))
         )
        )
      )
  )

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
