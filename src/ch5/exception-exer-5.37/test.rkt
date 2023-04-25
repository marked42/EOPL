#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../shared/test.rkt" (run-tests run-test-exception run-test-wrong-number-of-args)]
 ["interpreter.rkt" (run)]
 )

; (run-tests run)
; (run-test-exception run)
(run-test-wrong-number-of-args run)
