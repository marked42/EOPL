#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require  "../../base/test.rkt" "../../../base/test.rkt")

(define test-cases-export-module
  (list
   (list "
module m1
    interface [
        u : int
        n : [v : int]
    ]
    body
        module m2
            interface [v : int]
            body [v = 33]
        [u = 44 n = m2]
from m1 take n take v
      " 33 "local module definition")
   )
  )

(test-lang run sloppy->expval
           (append
            ; test-cases-simple-modules
            ; test-cases-local-module
            test-cases-export-module
            )
           )
