#lang eopl

(require "expression.rkt")
(provide (all-defined-out))

(define the-lexical-spec
  '((whitespace (whitespace) skip)
    (comment ("%" (arbno (not #\newline))) skip)
    (identifier
     (letter (arbno (or letter digit "_" "-" "?")))
     symbol)
    (number (digit (arbno digit)) number)
    (number ("-" digit (arbno digit)) number)
    ))

(define the-grammar
  '((program (expression) a-program)
    (expression (number) const-exp)
    (expression (identifier) var-exp)

    (expression ("(" top-level-call-exp ")") top-level-call-exp)

    (top-level-call-exp ("-" expression expression) diff-exp)

    (top-level-call-exp ("zero?" expression) zero?-exp)

    (top-level-call-exp ("if" expression expression expression) if-exp)

    (top-level-call-exp ("let" identifier expression expression) let-exp)

    (top-level-call-exp ("proc" identifier expression) proc-exp)
    (top-level-call-exp (expression expression) custom-call-exp)
    )
  )

(define scan&parse (sllgen:make-string-parser the-lexical-spec the-grammar))
