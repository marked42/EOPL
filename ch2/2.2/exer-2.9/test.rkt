#lang eopl

(require rackunit "environment.rkt" "../../test.rkt")

(test-environment empty-env extend-env apply-env)
(test-has-binding? empty-env extend-env has-binding?)
