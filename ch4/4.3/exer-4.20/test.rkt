#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
  (append
   test-cases-letrec-lang-with-multiple-declarations
   test-cases-begin-exp
   test-cases-letmutable-exp
   (list
    (list "let a = 1 in begin set a = 2; a end" 'error "let declares immutable variable, it's not assignable")
   )
   )
)
