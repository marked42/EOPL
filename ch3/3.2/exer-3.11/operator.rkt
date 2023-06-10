#lang eopl

(provide (all-defined-out))

(define-datatype operator operator?
  (binary-diff)
  (binary-sum)
  (binary-mul)
  (binary-div)
  (unary-zero?)
  (unary-minus)
)
