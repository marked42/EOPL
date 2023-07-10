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

   (list "var x,y; {x = 3; y = 4; print +(x,y)}" 7 "example 1")

   (list "
var x,y,z; {
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
var x; {
  x = 3;
  print x;
  var x;
  {
    x = 4;
    print x
  };
  print x
}
   " 3 "example 3")

   (list "
var f,x; {
  f = proc(x,y) *(x,y);
  x = 3;
  print (f 4 x)
}
   " 12 "example 4")
   )
  )

(test-lang run sloppy->expval test-cases-statement)
