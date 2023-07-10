#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
           (append
            test-cases-implicit-refs-lang
            ; test-cases-call-by-reference
            )
           )

(define test-cases-call-by-reference
  (list
   (list "
let p = proc (x) set x = 4
      in let a = 3
         in begin (p ref a); a end
    " 4 "call-by-reference")

   (list "
let p = proc (x) set x = 4
      in let a = 3
         in begin (p a); a end
    " 3 "call-by-value")

   (list "
     let f = proc (x) set x = 44 in let g = proc (y) (f ref y)
           in let z = 55
             in begin (g z); z end
      " 55 "call-by-value")

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
     " -11 "won't swap two values under call by value")
   )
  )
