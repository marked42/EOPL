#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
           (append
            test-cases-call-by-reference-lang
            (list
             (list "
let swap = proc (x, y) let temp = x
                  in begin
                      set x = y;
                      set y = temp
                     end
      in let a = 33
         in let b = 44
            in begin
                (swap a b);
                -(a,b)
            end
  " 11 "procedure support multiple arguments"))
            )
           )
