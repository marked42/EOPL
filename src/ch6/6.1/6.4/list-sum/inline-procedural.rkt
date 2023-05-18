#lang eopl

(require "test.rkt")

(define (list-sum lst)
  (list-sum/k lst (lambda (val)
                    (eopl:printf "End of computation.~%")
                    (eopl:printf "This sentence should appear only once.~%")
                    val
                    ))
  )

(define (list-sum/k lst cont)
  (if (null? lst)
      (cont 0)
      (let ((first (car lst)) (rest (cdr lst)))
        (list-sum/k rest (lambda (val)
                           (cont (+ first val))
                           ))
        )
      )
  )

(test-list-sum list-sum)
