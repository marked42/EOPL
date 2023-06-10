#lang eopl

(provide (all-defined-out))

(define-datatype expression expression?
  (const-exp (num number?))
  (var-exp (var symbol?))
  (diff-exp (exp1 expression?) (exp2 expression?))
  (zero?-exp (exp1 expression?))
  (if-exp (exp1 expression?) (exp2 expression?) (exp3 expression?))
  (let-exp
   (var symbol?)
   (exp1 expression?)
   (body expression?)
   )
  (letproc-exp (p-name symbol?) (b-var symbol?) (p-body expression?) (body expression?))
  (call-exp (rator expression?) (rand expression?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
