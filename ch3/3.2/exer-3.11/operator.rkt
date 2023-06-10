#lang eopl

(provide (all-defined-out))

(define-datatype operator operator?
  (binary-diff)
  (unary-zero?)
  (unary-minus)
)
