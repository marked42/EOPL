#lang eopl

(require "environment.rkt" "../../test.rkt")

(test-environment empty-env extend-env apply-env)
(test-empty-env? empty-env empty-env? extend-env)
(test-has-binding? empty-env extend-env has-binding?)
