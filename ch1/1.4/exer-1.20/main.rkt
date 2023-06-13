#lang eopl

(provide (all-defined-out))

(define (count-occurrences s slist)
  (define (count-occurrences-list l)
    (if (null? l)
        0
        (let ((first (car l)) (rest (cdr l)))
          (+
           (count-occurrences-element first)
           (count-occurrences-list rest)
           )
          )
        )
    )

  (define (count-occurrences-element element)
    (cond ((list? element)
           (count-occurrences-list element))
          ((eq? element s) 1)
          (else 0)
          )

    )
  (count-occurrences-list slist)
  )
