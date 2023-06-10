#lang eopl

(require "operator.rkt")
(provide (all-defined-out))

(define-datatype expression expression?
  (const-exp (num number?))
  (var-exp (var symbol?))
  (if-exp (exp1 expression?) (exp2 expression?) (exp3 expression?))
  (let-exp
   (var symbol?)
   (exp1 expression?)
   (body expression?)
   )
  (numeric-exp (op operator?) (exps (list-of expression?)))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
