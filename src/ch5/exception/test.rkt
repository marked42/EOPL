#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../shared/test.rkt" (run-tests)]
 ["interpreter.rkt" (run)]
 )

(run-tests run)
