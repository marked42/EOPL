#lang eopl

(provide (all-defined-out))

(define the-grammar
  '((cps-out-program (tfexp) cps-a-program)

    (simple-expression (number) cps-const-exp)

    (simple-expression (identifier) cps-var-exp)

    (simple-expression
     ("-" "(" simple-expression "," simple-expression ")")
     cps-diff-exp)

    (simple-expression
     ("zero?" "(" simple-expression ")")
     cps-zero?-exp)

    (simple-expression
     ("+" "(" (separated-list simple-expression ",") ")")
     cps-sum-exp)

    (simple-expression
     ("proc" "(" (separated-list identifier ",") ")" tfexp)
     cps-proc-exp)

    (tfexp
     (simple-expression)
     simple-exp->exp)

    (tfexp
     ("let" identifier "=" simple-expression "in" tfexp)
     cps-let-exp)

    (tfexp
     ("letrec"
      (arbno identifier "(" (separated-list identifier ",") ")"
             "=" tfexp)
      "in"
      tfexp)
     cps-letrec-exp)

    (tfexp
     ("if" simple-expression "then" tfexp "else" tfexp)
     cps-if-exp)

    (tfexp
     ("(" simple-expression (arbno simple-expression) ")")
     cps-call-exp)

    ))
