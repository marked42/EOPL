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
    (expression ("zero?" "(" expression ")") zero?-exp)

    (expression ("if" expression "then" expression "else" expression) if-exp)

    (expression ("let" identifier "=" expression "in" expression) let-exp)

    (expression ("proc" "(" identifier ")" expression) proc-exp)
    (expression ("("expression expression")" ) call-exp)

    (expression ("letrec" (arbno identifier "(" identifier ")" "=" expression) "in" expression) letrec-exp)

    (expression ("begin" expression (arbno ";" expression) "end") begin-exp)

    (expression ("set" identifier "=" expression) assign-exp)

    ; new stuff
    (expression ("newarray" "("expression "," expression")") newarray-exp)
    (expression ("arrayref" "(" expression"," expression")") arrayref-exp)
    (expression ("arrayset" "(" expression"," expression "," expression ")") arrayset-exp)
    (expression ("arraylength" "(" expression ")") arraylength-exp)
    )
  )

(define scan&parse (sllgen:make-string-parser the-lexical-spec the-grammar))
