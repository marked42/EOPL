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
 ;  "%let 3 in %let %lexproc -(%lexref 0, %lexref 1) in (%lexref 0 13)"
 ; f in inlined with its definition, depth of variable x is adjusted from
 ; 1 (depth at def site) to 2 (depth at call site) by 1 (offset of f)
 "%let 3 in %let %lexproc -(%lexref 0, %lexref 1) in (%lexproc -(%lexref 0, %lexref 2) 13)"
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
 "%let 3 in %let 4 in %let %lexproc -(%lexref 0, %lexref 2) in %let %lexproc -(%lexref 0, %lexref 2) in -((%lexproc -(%lexref 0, %lexref 4) 13), (%lexproc -(%lexref 0, %lexref 3) 14))"
 "print-program"
 )
