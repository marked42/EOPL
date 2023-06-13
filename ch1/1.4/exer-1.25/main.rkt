#lang eopl

(provide (all-defined-out))

(define (exists? pred lst)
  (if (null? lst)
      #f
      (let ((first (car lst)) (rest (cdr lst)))
        (if (pred first)
            #t
            (exists? pred rest)
            )
        )
      )
  )
