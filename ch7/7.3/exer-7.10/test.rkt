#lang eopl

(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
           (append
            test-cases-checked-lang
            test-cases-ref-exp
            (list
             (list "let a = 1 in (proc (x: refto int) deref(x) newref(a))" 1 "proc with parameter of ref type")
             (list "let a = 1 in (proc (x: refto int) x a)" 'error "type int and ref type of int are not same type")
             (list "let a = 1 in (proc (x: refto bool) x a)" 'error "type bool and ref type int are not same type")
             )
            )
           )
