#lang eopl

(require "environment.rkt" "../../test.rkt")

(test-environment empty-env extend-env apply-env)
(test-environment* empty-env extend-env* apply-env)
