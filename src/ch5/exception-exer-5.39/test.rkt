#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../shared/test.rkt" (run-tests run-test-exception equal-answer?)]
 ["interpreter.rkt" (run)]
 )

(run-tests run)

(equal-answer? (run "
try
    let v = raise 2
        in -(v, 1)
catch (m) -(m, 1)
") 0 "catch exception and continue from where raise was invoked")

(equal-answer? (run "
try
    let v = raise raise 2
        in -(v, 1)
catch (m) -(m, 1)
") -1 "nested raise cause mutliple executions")
