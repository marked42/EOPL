#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../../base/test.rkt")

(test-lang run sloppy->expval
    (append
        test-cases-proc-lang
        test-cases-let-exp-with-multiple-declarations
        test-cases-dynamic-scoping
        (list
            (list "
let fact = proc (n) add1(n)
    in let fact = proc (n)
                        if zero?(n)
                        then 1
                        % fact refers to fact at line 2 under dynamic scoping
                        else *(n, (fact -(n,1)))
            in (fact 5)
            " 120 "recurisve expression by dynamic scoping")
        )
    )
)
