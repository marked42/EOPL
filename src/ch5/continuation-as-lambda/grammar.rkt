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

    ; list
    (expression ("emptylist") emptylist-exp)
    (expression ("null?" "(" expression ")") null?-exp)
    (expression ("cons" "(" expression "," expression ")") cons-exp)
    (expression ("car" "(" expression ")") car-exp)
    (expression ("cdr" "(" expression ")") cdr-exp)
    (expression ("list" "(" expression (arbno "," expression)")") list-exp)

    (expression ("begin" expression (arbno ";" expression) "end") begin-exp)

    ; assign
    (expression ("set" identifier "=" expression) assign-exp)
    )
  )