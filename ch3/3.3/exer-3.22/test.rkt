#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
    (append
        test-cases-const-exp
        (list
            (list "(- 1 2)" -1 "diff-exp")
        )
        ; test-cases-zero?-exp
        (list
            (list "(zero? 0)" #t "zero?-exp")
            (list "(zero? 1)" #f "zero?-exp")
        )
        test-cases-var-exp
        ; test-cases-if-exp
        (list
            (list "(if (zero? 0) 2 3)" 2 "if exp")
            (list "(if (zero? 1) 2 3)" 3 "if exp")
        )
        ; test-cases-let-exp
        (list
            (list "(let a 1 (- a x))" -9 "let exp")
        )
        ; test-cases-proc-exp/test-cases-call-exp
        (list
            (list "(let f (proc x (- x 11)) (f (f 77)))" 55 "proc-exp")
            (list "((proc f (f (f 77))) (proc x (- x 11)))" 55 "proc-exp")
        )
    )
)
