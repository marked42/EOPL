#lang eopl

(require "expression.rkt")
(require "operator.rkt")
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

    (expression (operator "(" (separated-list expression ",")")") numeric-exp)
    (operator ("-") binary-diff)
    (operator ("zero?") unary-zero?)

    (expression ("if" expression "then" expression "else" expression) if-exp)

    (expression ("let" identifier "=" expression "in" expression) let-exp)
    )
  )

(define scan&parse (sllgen:make-string-parser the-lexical-spec the-grammar))
