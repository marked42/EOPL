#lang eopl

(require racket/lazy-require)
(lazy-require
 ["interpreter.rkt" (run)]
 ["value.rkt" (equal-answer?)]
 ["../../../base/test.rkt" (test-let-lang)]
 )

(test-let-lang run equal-answer?)
