#lang eopl

(require "expression.rkt")
(require "checker/type.rkt")
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

    (expression ("proc" "(" identifier ":" type")" expression) proc-exp)
    (expression ("("expression expression")" ) call-exp)

    (expression ("letrec" type identifier "(" identifier ":" type ")" "=" expression "in" expression) letrec-exp)

    (type ("int") int-type)
    (type ("bool") bool-type)
    (type ("(" type "->" type")") proc-type)
    (type ("pairof" type "*" type) pair-type)

    ; new stuff
    (expression ("pair" "(" expression "," expression ")") newpair-exp)
    (expression ("left" "(" expression ")") left-exp)
    (expression ("right" "(" expression ")") right-exp)
    (expression ("setleft" "(" expression "," expression ")") setleft-exp)
    (expression ("setright" "(" expression "," expression ")") setright-exp)
    )
  )

(define scan&parse (sllgen:make-string-parser the-lexical-spec the-grammar))