#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../cps-lang/interpreter.rkt" (run)]
 ["../cps-lang/test.rkt" (test-cps-lang)]
 ["transformer.rkt" (cps-of-program)]
 ["test-transformer.rkt" (test-transformer)]
 )

(provide (all-defined-out))

(test-transformer cps-of-program)
(test-cps-lang (lambda (str) (run str cps-of-program)))
