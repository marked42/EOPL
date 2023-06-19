#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
           (append
            test-cases-implicit-refs-lang
            (list
             (list "
letrec times4(x) = if zero?(x) then 0 else -((times4 -(x,1)), -4)
    in (times4 3)
    " 12 "recursive by letrec")
             (list "
let times4 = 0
      in begin
            set times4 = proc (x)
                            if zero?(x)
                            then 0
                            else -((times4 -(x,1)), -4);
            (times4 3)
        end

             " 12 "recursive by assignment")
             )
            )
           )
