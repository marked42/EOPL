#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
           (append
            test-cases-checked-lang
            test-cases-typed-list
            test-cases-typed-oo
            test-cases-exer-9.41
            )
           )
