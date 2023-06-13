#lang eopl

(provide (all-defined-out))

(define (list-index pred lst)
  (if (null? lst)
      #f
      (let ((first (car lst)) (rest (cdr lst)))
        (if (pred first)
            0
            (let ((index (list-index pred rest)))
              (if (number? index)
                  (+ 1 index)
                  #f
                  )
              )
            )
        )
      )
  )
