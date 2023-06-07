#lang eopl

(require racket rackunit)
(require "interpreter.rkt")
(require "value.rkt")
(require "../../../base/test.rkt")

(test-lang run sloppy->expval
           (append
            test-cases-let-lang
            test-cases-cond-exp
            )
           )

(check-exn exn:fail? (lambda () (run "cond zero?(1) ==> 1 zero?(2) ==> 2 end")))
