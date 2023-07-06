#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-fixed-point
  (list
   (list "
let makerec = proc (f)
                let d = proc (x)
                            proc (z) ((f (x x)) z)
                     in proc (n) ((f (d d)) n)
    in let maketimes4 = proc (f)
                            proc (x)
                                if zero?(x)
                                then 0
                                else -((f -(x,1)), -4)
        in let times4 = (makerec maketimes4)
            in (times4 3)
   " 12 "generalized fixed-point")
   )
  )

(test-lang run sloppy->expval test-cases-fixed-point)
