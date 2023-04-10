#lang eopl

(provide (all-defined-out))

(define the-grammar
  '((program (expression) a-program)
    (expression (number) const-exp)
    (expression (identifier) var-exp)
    (expression ("let" (arbno identifier "=" expression) "in" expression) let-exp)
    (expression ("letrec" (arbno identifier "(" (separated-list identifier ",") ")" "=" expression) "in" expression) letrec-exp)

    ; arithmetic
    (expression ("-" "(" expression "," expression ")") diff-exp)
    (expression ("zero?" "(" expression ")") zero?-exp)

    ; control
    (expression ("if" expression "then" expression "else" expression) if-exp)

    (expression ("proc" "(" identifier (arbno "," identifier) ")" expression) proc-exp)
    (expression ("(" expression (arbno expression) ")") call-exp)

    (expression ("begin" expression (arbno ";" expression) "end") begin-exp)

    (expression ("set" identifier "=" expression) assign-exp)

    ; mut-pair
    (expression ("pair" "(" expression "," expression ")") newpair-exp)
    (expression ("left" "(" expression ")") left-exp)
    (expression ("right" "(" expression ")") right-exp)
    (expression ("setleft" "(" expression "," expression ")") setleft-exp)
    (expression ("setright" "(" expression "," expression ")") setright-exp)

    ; array
    (expression ("newarray" "("expression "," expression")") newarray-exp)
    (expression ("arrayref" "("expression "," expression")") arrayref-exp)
    (expression ("arrayset" "("expression "," expression "," expression ")") arrayset-exp)
    (expression ("arraylength" "("expression")") arraylength-exp)
    )
  )
