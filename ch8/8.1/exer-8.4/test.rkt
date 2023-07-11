#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../base/test.rkt" "../../../base/test.rkt")

(test-lang run sloppy->expval
           (
            append
            test-cases-simple-modules
            test-cases-let-with-mutliple-declarations
            tests-cases-checked-letrec-with-multiple-declarations
            )
           )
