#lang eopl

(provide (all-defined-out))

(define cps-in-grammar
  '((program (expression) a-program)
    (expression (number) const-exp)
    (expression (identifier) var-exp)

    ; arithmetic
    (expression ("-" "(" expression "," expression ")") diff-exp)
    (expression ("zero?" "(" expression ")") zero?-exp)

    ; control
    (expression ("if" expression "then" expression "else" expression) if-exp)

    (expression ("proc" "(" (separated-list identifier ",") ")" expression) proc-exp)
    (expression ("(" expression (arbno expression) ")") call-exp)

    (expression ("+" "(" (separated-list expression ",") ")") sum-exp)

    (expression ("let" (arbno identifier "=" expression) "in" expression) let-exp)
    (expression ("letrec" (arbno identifier "(" (separated-list identifier ",") ")" "=" expression) "in" expression) letrec-exp)

    (expression ("list" "(" (separated-list expression ",") ")") list-exp)

    (expression ("print" "(" expression ")") print-exp)

    ; explicit refs
    (expression ("newref" "(" expression ")") newref-exp)
    (expression ("deref" "(" expression ")") deref-exp)
    (expression ("setref" "(" expression "," expression")") setref-exp)

    (expression ("begin" (separated-list expression ";") "end") begin-exp)
    )
  )
