#lang eopl

(require "../../shared/test-list-sum.rkt")

(define lst 'uninitialized)
(define sum 'unitiaizlied)
(define saved-cont 'unitialized)

(define (list-sum arg-lst)
  (set! lst arg-lst)
  (set! saved-cont (end-cont))
  (list-sum/k)
  )

(define (list-sum/k)
  (if (null? lst)
      (begin
        (set! sum 0)
        (saved-cont)
        )
      (let ((first (car lst)) (rest (cdr lst)))
        (set! saved-cont (sum-cont saved-cont first))
        (set! lst rest)
        (list-sum/k)
        )
      )
  )

(define (end-cont)
  (lambda ()
    (eopl:printf "End of computation.~%")
    (eopl:printf "This sentence should appear only once.~%")
    sum
    )
  )

(define (sum-cont saved-cont first)
  (lambda ()
    (set! sum (+ first sum))
    (saved-cont)
    )
  )

(test-list-sum list-sum)
