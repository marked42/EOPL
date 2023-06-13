#lang eopl

(provide (all-defined-out))

(define (every? pred lst)
  (if (null? lst)
      #t
      (let ((first (car lst)) (rest (cdr lst)))
        (if (pred first)
            (every? pred rest)
            #f
            )
        )
      )
  )
