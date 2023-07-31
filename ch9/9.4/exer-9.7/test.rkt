#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-exer-9.7
  (list
   (list "
class c1 extends object
  field ivar1
  method initialize() set ivar1 = 1

class c2 extends c1
  field ivar2
  method initialize()
   begin
    super initialize();
    set ivar2 = 2
   end
  method setiv1(n) set ivar1 = n  %execute error
  method getiv1()  ivar1          %execute error
  method setiv2(n) set ivar2 = n
  method getiv2()  ivar2

let o = new c2 ()
    t1 = 0
in begin
       send o setiv2(33);
       send o getiv2()
   end
            " 33 "limit fields")
   )
  )

(test-lang run sloppy->expval
           (append
            test-cases-implicit-refs-lang
            test-cases-let-exp-with-multiple-declarations
            test-cases-sum-exp
            test-cases-list-v2
            test-cases-proc-exp-with-multiple-arguments
            test-cases-exer-9.7
            )
           )
