#lang eopl

(provide (all-defined-out))

(define-datatype method-modifier method-modifier?
    (public-modifier)
    (private-modifier)
    (protected-modifier)
)
