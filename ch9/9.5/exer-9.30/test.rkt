#lang eopl

(require "../typed-oo/interpreter.rkt")
(require "../typed-oo/value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
           (append
            test-cases-checked-lang
            test-cases-typed-list
            test-cases-typed-oo
            test-cases-9.30
            )
           )
