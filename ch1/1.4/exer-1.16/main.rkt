#lang eopl

(provide (all-defined-out))

(define (invert lst)
  (if (null? lst)
      '()
      (let ((first (car lst)) (rest (cdr lst)))
        (cons
         (list (cadr first) (car first))
         (invert rest)
         )
        )
      )
  )
