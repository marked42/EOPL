#lang eopl

(require "../classes/interpreter.rkt")
(require "../classes/value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
           (append
            test-cases-bogus-odd-even
            )
           )
