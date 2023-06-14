#lang eopl

(require rackunit "interpreter.rkt" "parser.rkt" "printer.rkt" "translator.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval test-cases-proc-lang)

(check-equal?
 (print-program (scan&parse "
let x = 3
    in let f = proc (y) -(y,x)
        in (f 13)
"))
 "let x = 3 in let f = proc (y) -(y, x) in (f 13)"
 "print-program"
 )

(check-eq?
 (print-program (translation-of-program (scan&parse "
let x = 3
    in let f = proc (y) -(y,x)
        in (f 13)
")))
 "%let 3 in %let %lexproc -(%lexref 0, %lexref 1) in (%lexref 0 13)"
 "print-program"
 )
