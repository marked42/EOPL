#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
           (append
            test-cases-simple-modules
            test-cases-opaque-types
            test-cases-proc-modules
            test-cases-declared-interface
            )
           )
