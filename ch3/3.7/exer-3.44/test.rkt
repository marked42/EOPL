#lang eopl

(require rackunit "interpreter.rkt" "parser.rkt" "printer.rkt" "translator.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
           (append
            test-cases-proc-lang
            (list
             (list " let x = 3 in let f = proc (y) -(y, x) in (f 13) " 10 "print-program")
             (list "
let x = 3
    in let p = 4
        in let f = proc (y) -(y, x)
            in let g = proc (z) -(z, p)
                in -((f 13), (g 14))
             " 0 "print-program")
             )
            )
           )

(check-equal?
 (print-program (scan&parse "
let x = 3
    in let f = proc (y) -(y,x)
        in (f 13)
"))
 "let x = 3 in let f = proc (y) -(y, x) in (f 13)"
 "print-program"
 )

(check-equal?
 (print-program (translation-of-program (scan&parse "
let x = 3
    in let f = proc (y) -(y, x)
        in (f 13)
")))
 "%let 3 in (%lexproc -(%lexref 0, %lexref 1) 13)"
 "print-program"
 )

(check-equal?
 (print-program (translation-of-program (scan&parse "
let x = 3
    in let p = 4
        in let f = proc (y) -(y, x)
            in let g = proc (z) -(z, p)
                in -((f 13), (g 14))
")))
 "%let 3 in %let 4 in -((%lexproc -(%lexref 0, %lexref 2) 13), (%lexproc -(%lexref 0, %lexref 1) 14))"
 "print-program"
 )
