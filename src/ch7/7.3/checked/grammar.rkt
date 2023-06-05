#lang eopl

(provide (all-defined-out))

(define-datatype type type?
  (int-type)
  (bool-type)
  (proc-type (arg-types (list-of type?)) (result-type type?))
  )

(define the-grammar
  '((program (expression) a-program)
    (expression (number) const-exp)
    (expression (identifier) var-exp)
    (expression ("-" "(" expression "," expression ")") diff-exp)
    (expression ("zero?" "(" expression ")") zero?-exp)

    (expression ("if" expression "then" expression "else" expression) if-exp)

    (expression ("let" identifier "=" expression "in" expression) let-exp)
    (expression ("letrec" type identifier "(" (arbno identifier ":" type) ")" "=" expression "in" expression) letrec-exp)

    (expression ("proc" "(" (arbno identifier ":" type) ")" expression) proc-exp)
    (expression ("(" expression (arbno expression) ")") call-exp)

    (type ("int") int-type)
    (type ("bool") bool-type)
    (type ("(" (arbno type) "->" type ")") proc-type)
    )
  )
