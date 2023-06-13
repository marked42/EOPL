#lang eopl

(provide (all-defined-out))

(define (list-set lst n x)
  (if (null? lst)
      '()
      (let ((first (car lst)) (rest (cdr lst)))
        (cond ((< n 0) (eopl:error "index ~s too large" n))
              ((= n 0)
               (cons x rest)
               )
              (else (cons first (list-set rest (- n 1) x)))
              )
        )
      )
  )
