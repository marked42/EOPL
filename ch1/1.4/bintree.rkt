#lang eopl

(provide (all-defined-out))

; Bintree::=Int |(Symbol Bintree Bintree)

(define (leaf? node) (number? node))

(define (leaf node)
  (if (leaf? node)
      node
      (eopl:error "leaf accepts only number, get ~s." node)
      )
  )

(define (interior-node s left right) (list s left right))

(define (lson n)
  (if (leaf? n)
      (eopl:error "lson accetps only interior node, get leaf ~s" n)
      (cadr n)
      )
  )

(define (rson n)
  (if (leaf? n)
      (eopl:error "rson accetps only interior node, get leaf ~s" n)
      (caddr n)
      )
  )

(define (contents-of n)
  (if (leaf? n)
      n
      (car n)
      )
  )
