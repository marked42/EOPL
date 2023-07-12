#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(define test-cases-import
  (list
   (list "
module m1
    interface []
    body [x = print(1)]
module m2
    interface []
    body [x = print(2)]
module m3
    interface []
    body [x = print(3)]
33
      " 33 "import module on demand")
   )
  )

(test-lang run sloppy->expval
    (append
        test-cases-simple-modules
        test-cases-import
    )
)