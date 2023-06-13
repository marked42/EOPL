#lang eopl

(require "environment.rkt" "../../test.rkt")

(test-empty-env? empty-env empty-env? extend-env)
