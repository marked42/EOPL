#lang eopl

(provide (all-defined-out))

(define (empty-queue) '())

(define (empty? queue) (null? queue))

(define (enqueue queue item)
  (append queue (list item))
  )

(define (dequeue queue f)
  (f (car queue) (cdr queue))
  )
