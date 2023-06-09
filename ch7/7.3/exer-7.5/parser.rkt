#lang eopl

(require "expression.rkt")
(require "checker/type.rkt")
(require "typed-var.rkt")
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
    (expression ("zero?" "(" expression ")") zero?-exp)

    (expression ("if" expression "then" expression "else" expression) if-exp)

    (expression ("let" (arbno identifier "=" expression) "in" expression) let-exp)

    (expression ("proc" "("(separated-list typed-var ",") ")" expression) proc-exp)
    (expression ("("expression (arbno expression)")" ) call-exp)

    (expression ("letrec" type identifier "(" typed-var ")" "=" expression "in" expression) letrec-exp)

    (typed-var (identifier ":" type) a-typed-var)

    (type ("int") int-type)
    (type ("bool") bool-type)
    (type ("(" (separated-list type "*")"->" type")") proc-type)
    )
  )

(define scan&parse (sllgen:make-string-parser the-lexical-spec the-grammar))
