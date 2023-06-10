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

    (expression ("-" "(" expression "," expression ")") diff-exp)

    (expression ("if" bool-exp "then" expression "else" expression) if-exp)

    (expression ("let" identifier "=" expression "in" expression) let-exp)

    ; new stuff
    (expression (bool-exp) top-level-bool-exp)

    (bool-exp ("zero?" "(" expression ")") zero?-exp)
    (bool-exp ("equal?" "(" expression "," expression ")") equal?-exp)
    (bool-exp ("greater?" "(" expression "," expression ")") greater?-exp)
    (bool-exp ("less?" "(" expression "," expression ")") less?-exp)
    )
  )

(define scan&parse (sllgen:make-string-parser the-lexical-spec the-grammar))
