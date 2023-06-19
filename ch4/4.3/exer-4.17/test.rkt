#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
           (append
            test-cases-implicit-refs-lang
            test-cases-proc-exp-with-multiple-arguments
            test-cases-let-exp-with-multiple-declarations
            )
           )
