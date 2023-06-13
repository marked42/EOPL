#lang eopl

(provide (all-defined-out))

(define (duple n x)
  (if (zero? n)
      '()
      (cons x (duple (- n 1) x))
      )
  )
