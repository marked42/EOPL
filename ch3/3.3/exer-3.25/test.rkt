#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-fixed-point
  (list
   (list "
let makemult = proc (maker)
                proc (x)
                    if zero?(x)
                    then 0
                    else -(((maker maker) -(x,1)), -4)
    in let times4 = proc (x) ((makemult makemult) x)
        in (times4 3)
   " 12 "times4 by fixed point")

   (list "
let maketimes = proc (maker)
                proc (x)
                    proc (y)
                        if zero?(x)
                        then 0
                        else -((((maker maker) -(x,1)) y), -(0, y))
    in let times = proc (x) proc (y) (((maketimes maketimes) x) y)
        in ((times 4) 3)
   " 12 "times by fixed point")

   (list "
let maketimes = proc (maker)
                proc (x)
                    proc (y)
                        if zero?(x)
                        then 0
                        else -((((maker maker) -(x,1)) y), -(0, y))
    in let times = proc (x)
                        proc (y)
                            (((maketimes maketimes) x) y)
        in let makefact = proc (maker)
                        proc (x)
                            if zero?(x)
                            then 1
                            else ((times x) ((maker maker) -(x, 1)))
            in let fact = proc (x)
                            ((makefact makefact) x)
                in (fact 0)
   " 1 "fact(0) = 1")

   (list "
let maketimes = proc (maker)
                proc (x)
                    proc (y)
                        if zero?(x)
                        then 0
                        else -((((maker maker) -(x,1)) y), -(0, y))
    in let times = proc (x)
                        proc (y)
                            (((maketimes maketimes) x) y)
        in let makefact = proc (maker)
                        proc (x)
                            if zero?(x)
                            then 1
                            else ((times x) ((maker maker) -(x, 1)))
            in let fact = proc (x)
                            ((makefact makefact) x)
                in (fact 1)
   " 1 "fact(1) = 1")

   (list "
let maketimes = proc (maker)
                proc (x)
                    proc (y)
                        if zero?(x)
                        then 0
                        else -((((maker maker) -(x,1)) y), -(0, y))
    in let times = proc (x)
                        proc (y)
                            (((maketimes maketimes) x) y)
        in let makefact = proc (maker)
                        proc (x)
                            if zero?(x)
                            then 1
                            else ((times x) ((maker maker) -(x, 1)))
            in let fact = proc (x)
                            ((makefact makefact) x)
                in (fact 2)
   " 2 "fact(2) = 2")

   (list "
let maketimes = proc (maker)
                proc (x)
                    proc (y)
                        if zero?(x)
                        then 0
                        else -((((maker maker) -(x,1)) y), -(0, y))
    in let times = proc (x)
                        proc (y)
                            (((maketimes maketimes) x) y)
        in let makefact = proc (maker)
                        proc (x)
                            if zero?(x)
                            then 1
                            else ((times x) ((maker maker) -(x, 1)))
            in let fact = proc (x)
                            ((makefact makefact) x)
                in (fact 3)
   " 6 "fact(3) = 6")

   (list "
let make-even = proc (make-even)
                    proc (make-odd)
                        proc (x)
                            if zero?(x)
                            then 1
                            else (((make-odd make-odd) make-even) -(x, 1))
    in let make-odd = proc (make-odd)
                        proc (make-even)
                            proc (x)
                                if zero?(x)
                                then 0
                                else (((make-even make-even) make-odd) -(x, 1))
        in (((make-odd make-odd) make-even) 13)
   " 1 "mutually recursive")
   )
  )

(test-lang run sloppy->expval test-cases-fixed-point)
