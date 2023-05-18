#lang eopl

(require "test.rkt")

(define (remove-first item lst)
  (remove-first/k item lst (end-cont))
  )

(define (remove-first/k item lst cont)
  (if (null? lst)
      (apply-cont cont '())
      (let ((first (car lst)) (rest (cdr lst)))
        (if (eq? first item)
            (apply-cont cont rest)
            (remove-first/k item rest (remove-first-cont first cont))
            )
        )
      )
  )

(define-datatype continuation cont?
  (end-cont)
  (remove-first-cont (first number?) (saved-cont cont?))
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
    (remove-first-cont (first saved-cont)
                       (apply-cont saved-cont (cons first val))
                       )
    )
  )

(test-remove-first remove-first)
