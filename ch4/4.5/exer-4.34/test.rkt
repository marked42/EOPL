#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-letref-exp
  (list
   (list "
   let a = 1
    in letref b = a
        in begin
            set b = 2;
            a
        end
    " 2 "letref-exp")
   )
  )

(test-lang run sloppy->expval
           (append
            test-cases-call-by-reference-lang
            test-cases-letref-exp
            )
           )
