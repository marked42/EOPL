#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-zero?-exp-v2
  (list
   (list "zero?(0)" 1 "zero?-exp")
   (list "zero?(1)" 0 "zero?-exp")
   )
  )

(test-lang run sloppy->expval
           (append
            test-cases-const-exp
            test-cases-diff-exp
            test-cases-zero?-exp-v2
            test-cases-var-exp
            test-cases-if-exp
            test-cases-let-exp
            )
           )
