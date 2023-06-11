#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../../base/test.rkt")

(test-lang run sloppy->expval
    (append
        test-cases-proc-lang
        (list
            (list "
let fact = proc (n) add1(n)
    in let fact = proc (n)
                        if zero?(n)
                        then 1
                        % fact refers to fact at line under lexical scoping
                        else *(n, (fact -(n,1)))
            in (fact 5)
            " 25 "lexical scoping")
        )
    )
)
