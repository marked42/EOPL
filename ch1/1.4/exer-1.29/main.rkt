#lang eopl

(provide (all-defined-out))

(define (sort loi)
  (define (insert val loi)
    (if (null? loi)
        (list val)
        (let ((first (car loi)) (rest (cdr loi)))
          (if (< val first)
              (cons val loi)
              (cons first (insert val rest))
              )
          )
        )
    )

  (if (null? loi)
      '()
      (let ((first (car loi)) (rest (cdr loi)))
        (insert first (sort rest))
        )
      )
  )
