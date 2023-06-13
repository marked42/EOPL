#lang eopl

(require "../bintree.rkt")
(provide (all-defined-out))

(define (mark-leaves-with-red-depth tree)
  (define (helper t depth)
    (if (leaf? t)
        (leaf depth)
        (let ((content (contents-of t)) (left (lson t)) (right (rson t)))
          (interior-node
           content
           (helper left (+ depth (if (eq? content 'red) 1 0)))
           (helper right (+ depth (if (eq? content 'red) 1 0)))
           )
          )
        )
    )
  (helper tree 0)
  )
