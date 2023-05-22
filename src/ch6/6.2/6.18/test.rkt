#lang eopl

(require racket/lazy-require)
(lazy-require
 ["interpreter.rkt" (run)]
 ["../cps-out/value.rkt" (equal-answer?)]
 ["../cps-out/test.rkt" (test-cps-out-lang)]
 )

(provide (all-defined-out))

(test-cps-out-lang run equal-answer?)
