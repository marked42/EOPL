#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
    (append
        test-cases-proc-lang-with-multiple-arguments
        test-cases-letrec-lang
        test-cases-letrec-exp-with-multiple-arguments
    )
)
