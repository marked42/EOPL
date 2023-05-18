#lang eopl

(require "../../shared/test-list-sum.rkt")

(define (list-sum lst)
  (list-sum/k lst (end-cont))
  )

(define (list-sum/k lst cont)
  (if (null? lst)
      (apply-cont cont 0)
      (let ((first (car lst)) (rest (cdr lst)))
        (list-sum/k rest (sum-cont cont first))
        )
      )
  )

(define (end-cont)
  (lambda (val)
    (eopl:printf "End of computation.~%")
    (eopl:printf "This sentence should appear only once.~%")
    val
    )
  )

(define (sum-cont saved-cont first)
  (lambda (val)
    (apply-cont saved-cont (+ first val))
    )
  )

(define (apply-cont cont val)
  (cont val)
  )

(test-list-sum list-sum)
