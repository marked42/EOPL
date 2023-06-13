#lang eopl

(provide (all-defined-out))

(define (filter-in pred lst)
  (if (null? lst)
      '()
      (let ((first (car lst)) (rest (cdr lst)))
        (if (pred first)
            (cons first (filter-in pred rest))
            (filter-in pred rest))
        )
      )
  )
