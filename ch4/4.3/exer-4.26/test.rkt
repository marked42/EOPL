#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-statement
  (list
   (list "x = 3" 3 "assign statement")

   (list "print 3" 3 "print statement")

   (list "{ x = 3; print x } " 3 "block statement")

   (list "if zero?(0) { print 1 } { print 2 }" 1 "if statement")

   (list "var x = 1, y = 2; {x = 3; y = 4; print +(x,y)}" 7 "example 1")

   (list "
   var x = 1, y = 2, z = 3; {
     x = 3;
     y = 4;
     z = 0;
     while not(zero?(x)) {
       z = +(z,y); x = -(x,1)
     };
     print z
   }
      " 12 "example 2")

   (list "
   var x = 1; {
     x = 3;
     print x;
     var x = 2;
     {
       x = 4;
       print x
     };
     print x
   }
      " 3 "example 3")

   (list "
   var f = 1, x = 2; {
     f = proc(x,y) *(x,y);
     x = 3;
     print (f 4 x)
   }
      " 12 "example 4")

   (list "
   var x = 0; {
     read x;
     print 1
   }
      " 1 "example 4")

   (list "
   var x = 1, y = 2, z = 3; {
     x = 3;
     y = 4;
     z = 0;
     do-while not(zero?(x)) {
       z = +(z,y); x = -(x,1)
     };
     print z
   }
      " 12 "do while")

   (list "
    varrec odd  (x) if zero?(x) then 0 else (even -(x,1))
           even (x) if zero?(x) then 1 else (odd -(x,1)); {
       print (odd 13)
    }
       " 1 "mutually recursive proc declaration")
   )
  )

(test-lang run sloppy->expval test-cases-statement)
