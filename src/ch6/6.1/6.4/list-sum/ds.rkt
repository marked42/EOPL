#lang eopl

(require "test.rkt")

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

(define-datatype continuation cont?
  (end-cont)
  (sum-cont (saved-cont cont?) (first number?))
  )

(define (apply-cont cont val)
  (cases continuation cont
    (end-cont ()
              (begin
                (eopl:printf "End of computation.~%")
                (eopl:printf "This sentence should appear only once.~%")
                val
                )
              )
    (sum-cont (saved-cont first)
              (apply-cont saved-cont (+ first val))
              )
    )
  )

(test-list-sum list-sum)
