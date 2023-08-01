#lang eopl

(provide (all-defined-out))

(define-datatype final-modifier final-modifier?
  (non-final-method)
  (final-method)
)

(define (is-final m)
  (cases final-modifier m
    (non-final-method () #f)
    (final-method () #t)
  )
)
