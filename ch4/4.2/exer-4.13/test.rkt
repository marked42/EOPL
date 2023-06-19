#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
           (append
            test-cases-proc-exp-with-multiple-arguments
            test-cases-explicit-refs
            )
           )
