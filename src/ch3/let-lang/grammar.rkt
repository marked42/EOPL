#lang eopl

(require "expression.rkt")
(provide (all-defined-out))

(define the-grammar
  '((program (expression) a-program)
    (expression (number) const-exp)
    (expression (identifier) var-exp)
    (expression ("let" (arbno identifier "=" expression) "in" expression) let-exp)

    ; arithmetic
    (expression ("-" "(" expression "," expression ")") diff-exp)
    (expression ("+" "(" expression "," expression ")") sum-exp)
    (expression ("*" "(" expression "," expression ")") mul-exp)
    (expression ("/" "(" expression "," expression ")") div-exp)
    (expression ("minus" "(" expression  ")") minus-exp)
    (expression ("zero?" "(" expression ")") zero?-exp)

    ; comparision
    (expression ("equal?" "(" expression "," expression ")") equal?-exp)
    (expression ("greater?" "(" expression "," expression ")") greater?-exp)
    (expression ("less?" "(" expression "," expression ")") less?-exp)

    ; list
    (expression ("cons" "(" expression "," expression ")") cons-exp)
    (expression ("car" "(" expression ")") car-exp)
    (expression ("cdr" "(" expression ")") cdr-exp)
    (expression ("emptylist") emptylist-exp)
    (expression ("null?" "(" expression ")") null?-exp)
    (expression ("list" "(" expression (arbno "," expression)")") list-exp)

    ; control
    (expression ("if" expression "then" expression "else" expression) if-exp)

    (expression ("cond" (arbno expression "==>" expression) "end") cond-exp)

    (expression ("print" "(" expression ")") print-exp)
    )
  )
