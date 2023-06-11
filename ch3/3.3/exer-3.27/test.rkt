#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
    (append
        test-cases-proc-lang
        (list
            (list "let f = traceproc (x) -(x,11) in (f (f 77))" 55 "traceproc-exp")
            (list "(traceproc (f) (f (f 77)) traceproc (x) -(x,11))" 55 "traceproc-exp")
        )
    )
)
