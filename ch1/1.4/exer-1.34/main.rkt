#lang eopl

(require "../bintree.rkt")
(provide (all-defined-out))

(define (path n bst)
  (if (null? bst)
      '()
      (let ((content (contents-of bst)) (left (lson bst)) (right (rson bst)))
        (cond ((< n content)
               (cons 'left (path n left)))
              ((> n content)
               (cons 'right (path n right)))
              (else '())
              )
        )
      )
  )
