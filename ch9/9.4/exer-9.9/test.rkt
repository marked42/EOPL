#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
           (append
            test-cases-implicit-refs-lang
            test-cases-let-exp-with-multiple-declarations
            test-cases-sum-exp
            test-cases-list-v2
            test-cases-proc-exp-with-multiple-arguments
            test-cases-classes
            test-cases-fieldref-fieldset
            test-cases-super-field-ref-set
            )
           )
