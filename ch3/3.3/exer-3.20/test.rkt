#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
    (append
        test-cases-proc-lang
        test-cases-curried-sum
    )
)
