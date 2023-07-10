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
  '((program (statement) a-program)

    (statement (identifier "=" expression) assign-statement)
    (statement ("print" expression) print-statement)
    (statement ("{" (separated-list statement ";") "}") block-statement)
    (statement ("if" expression statement statement) if-statement)
    (statement ("while" expression statement) while-statement)
    (statement ("var" (separated-list identifier ",") ";" statement) var-statement)

    (expression (number) const-exp)
    (expression (identifier) var-exp)

    (expression ("-" "(" expression "," expression ")") diff-exp)
    (expression ("+" "(" expression "," expression ")") sum-exp)
    (expression ("*" "(" expression "," expression ")") mul-exp)
    (expression ("zero?" "(" expression ")") zero?-exp)
    (expression ("not" "(" expression ")") not-exp)

    (expression ("proc" "(" (separated-list identifier ",") ")" expression) proc-exp)
    (expression ("("expression (arbno expression)")" ) call-exp)
    )
  )

(define scan&parse (sllgen:make-string-parser the-lexical-spec the-grammar))
