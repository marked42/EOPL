#lang eopl

(require "test.rkt")

(define item 'uninitialized)
(define lst 'uninitialized)
(define saved-cont 'uninitialized)
(define answer 'uninitialized)

(define (remove-first item-arg lst-arg)
  (set! item item-arg)
  (set! lst lst-arg)
  (set! saved-cont (end-cont))
  (remove-first/k)
  )

(define (remove-first/k)
  (if (null? lst)
      (begin
        (set! answer '())
        (saved-cont)
        )
      (let ((first (car lst)) (rest (cdr lst)))
        (if (eq? first item)
            (begin
              (set! answer rest)
              (saved-cont)
              )
            (begin
              (set! saved-cont (remove-first-cont first saved-cont))
              (set! lst rest)
              (remove-first/k)
              )
            )
        )
      )
  )

(define (end-cont) (lambda ()
                     (eopl:printf "End of computation.~%")
                     (eopl:printf "This sentence should appear only once.~%")
                     answer
                     ))

(define (remove-first-cont first saved-cont)
  (lambda ()
    (set! answer (cons first answer))
    (saved-cont)
    )
  )

(test-remove-first remove-first)
