#lang eopl

(provide (all-defined-out))

(define (product sos1 sos2)
  (if (null? sos1)
      '()
      (let ((first (car sos1)) (rest (cdr sos1)))
        (append
         (map (lambda (s2) (list first s2)) sos2)
         (product rest sos2)
         )
        )
      )
  )
