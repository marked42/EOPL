#lang eopl

(require racket/lazy-require "value.rkt")
(lazy-require
 ["value.rkt" (num-val bool-val expval->num expval->bool)]
 )

(provide (all-defined-out))

(define (eval-diff-exp val1 val2)
  (let ((num1 (expval->num val1)) (num2 (expval->num val2)))
    (num-val (- num1 num2))
    )
  )

(define (eval-zero?-exp val1)
  (let ((num (expval->num val1)))
    (if (zero? num)
        (bool-val #t)
        (bool-val #f)
        )
    )
  )

(define (eval-if-exp val1 exp2 exp3)
  (let ((exp (if (expval->bool val1) exp2 exp3)))
    exp
    )
  )

(define (eval-car-exp val1)
  (cell-val->first val1)
  )

(define (eval-cdr-exp val1)
  (cell-val->second val1)
  )

(define (build-list-from-vals vals)
  (if (null? vals)
      (null-val)
      (let ((first (car vals)) (rest (cdr vals)))
        (cell-val first (build-list-from-vals rest))
        )
      )
  )