#lang eopl

(require "../bintree.rkt")
(provide (all-defined-out))

(define (number-leaves tree)
  (define index -1)

  (define (traverse node)
    (if (leaf? node)
        (begin
          (set! index (+ index 1))
          (leaf index)
          )
        (let ((content (contents-of node)) (left (lson node)) (right (rson node)))
          (interior-node
           content
           (traverse left)
           (traverse right)
           )
          )
        )
    )

  (traverse tree)
  )
