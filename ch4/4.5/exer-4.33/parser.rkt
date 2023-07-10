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
    (expression ("("expression operand")" ) call-exp)

    (operand ("ref" identifier) ref-operand)
    (operand (expression) value-operand)

    (expression ("letrec" (arbno identifier "(" identifier ")" "=" expression) "in" expression) letrec-exp)

    (expression ("begin" expression (arbno ";" expression) "end") begin-exp)

    ; new stuff
    (expression ("set" identifier "=" expression) assign-exp)
    )
  )

(define scan&parse (sllgen:make-string-parser the-lexical-spec the-grammar))
