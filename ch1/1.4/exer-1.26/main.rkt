#lang eopl

(provide (all-defined-out))

(define (up lst)
  (if (null? lst)
      '()
      (let ((first (car lst)) (rest (cdr lst)))
        (if (list? first)
            (append first (up rest))
            (cons first (up rest))
            )
        )
      )
  )
