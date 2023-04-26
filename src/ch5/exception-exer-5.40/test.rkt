#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../shared/test.rkt" (run-tests run-test-exception equal-answer?)]
 ["interpreter.rkt" (run)]
 )

(run-tests run)
(run-test-exception run)

(equal-answer? (run "
try -(1, raise 44) catch (m) -(m, 1)
") 43 "returns normally in try-catch handler")

(equal-answer? (run "
try -(1, raise 44) catch (m) continue(-(m, 1))
") -42 "use continue expression in try-catch handler to continue from where raise was invoked")

(equal-answer? (run "
try -(1, raise raise 44) catch (m) continue(-(m, 1))
") -41 "nested raise with continue")
