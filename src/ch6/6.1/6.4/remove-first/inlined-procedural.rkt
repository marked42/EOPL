#lang eopl

(require "test.rkt")

(define (remove-first item lst)
  (remove-first/k item lst (lambda (val)
                             (begin
                               (eopl:printf "End of computation.~%")
                               (eopl:printf "This sentence should appear only once.~%")
                               val
                               )
                             ))
  )

(define (remove-first/k item lst cont)
  (if (null? lst)
      (cont '())
      (let ((first (car lst)) (rest (cdr lst)))
        (if (eq? first item)
            (cont rest)
            (remove-first/k item rest
                            (lambda (val)
                              (cont (cons first val))
                              )
                            )
            )
        )
      )
  )

(test-remove-first remove-first)
