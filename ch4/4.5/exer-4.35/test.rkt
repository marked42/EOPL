#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-ref-var
  (list
   (list "
let p = proc (x) set x = 4
      in let a = 3
         in begin (p ref a); a end
    " 4 "call-by-reference")
   (list "
  let f = proc (x) set x = 44 in let g = proc (y) (f ref y)
        in let z = 55
          in begin (g ref z); z end
   " 44 "call-by-reference")

   (list "
let swap = proc (x) proc (y) let temp = x
                  in begin
                      set x = y;
                      set y = temp
                     end
      in let a = 33
         in let b = 44
            in begin
                ((swap ref a) ref b);
                -(a,b)
            end
  " 11 "swap two values under call by reference")
   )
  )

(test-lang run sloppy->expval
           (append
            test-cases-implicit-refs-lang
            test-cases-ref-var
            )
           )
