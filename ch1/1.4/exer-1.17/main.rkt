#lang eopl

(provide (all-defined-out))

(define (down lst)
  (if (null? lst)
      '()
      (let ((first (car lst)) (rest (cdr lst)))
        (cons
         (list first)
         (down rest)
         )
        )
      )
  )
