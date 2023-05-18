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

(define (end-cont) (lambda (val)
                     (begin
                       (eopl:printf "End of computation.~%")
                       (eopl:printf "This sentence should appear only once.~%")
                       val
                       )
                     ))

(define (remove-first-cont first saved-cont)
  (lambda (val)
    (apply-cont saved-cont (cons first val))
    )
  )

(define (apply-cont cont val)
  (cont val)
  )

(test-remove-first remove-first)
