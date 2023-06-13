#lang eopl

(provide (all-defined-out))

(define (flatten lst)
  (if (null? lst)
      '()
      (let ((first (car lst)) (rest (cdr lst)))
        (if (list? first)
            (append (flatten first) (flatten rest))
            (cons first (flatten rest))
            )
        )
      )
  )
