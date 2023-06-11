#lang eopl

(provide (all-defined-out))

(define-datatype expression expression?
  (const-exp (num number?))
  (var-exp (var symbol?))
  (diff-exp (exp1 expression?) (exp2 expression?))
  (zero?-exp (exp1 expression?))
  (if-exp (exp1 expression?) (exp2 expression?) (exp3 expression?))
  (let-exp
   (vars (list-of symbol?))
   (exps (list-of expression?))
   (body expression?)
   )
  (proc-exp (var symbol?) (body expression?))
  (call-exp (rator expression?) (rand expression?))

  ; new sutff
  (add1-exp (exp1 expression?))
  (mul-exp (exp1 expression?) (exp2 expression?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
