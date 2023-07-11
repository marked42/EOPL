#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../base/test.rkt" "../../../base/test.rkt")

(test-lang run sloppy->expval
           (
            append
            test-cases-let-with-mutliple-declarations
            test-cases-simple-modules
            tests-cases-checked-letrec-with-multiple-declarations
            test-cases-letrec-in-module-body
            test-cases-let-in-module-body
            )
           )
