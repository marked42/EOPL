#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
           (append
            test-cases-proc-lang
            test-cases-list-v1-exp
            ; test-cases-unpack-exp
            )
           )
