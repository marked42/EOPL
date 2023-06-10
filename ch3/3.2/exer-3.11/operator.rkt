#lang eopl

(provide (all-defined-out))

(define-datatype operator operator?
  (binary-diff)
  (binary-sum)
  (binary-mul)
  (binary-div)
  (binary-equal?)
  (binary-greater?)
  (binary-less?)
  (unary-zero?)
  (unary-minus)
)
