#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
    (append
        test-cases-implicit-refs-lang
        test-cases-array-exp
        test-cases-array-check-index-exp
        test-cases-array-length-exp
    )
)
