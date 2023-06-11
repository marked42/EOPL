#lang eopl

(provide (all-defined-out))

(define-datatype expression expression?
  (const-exp (num number?))
  (var-exp (var symbol?))

  (top-level-call-exp (exp1 call-exp?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )

(define-datatype call-exp call-exp?
  (diff-exp (exp1 expression?) (exp2 expression?))
  (zero?-exp (exp1 expression?))
  (if-exp (exp1 expression?) (exp2 expression?) (exp3 expression?))
  (let-exp
   (var symbol?)
   (exp1 expression?)
   (body expression?)
   )
  (proc-exp (var symbol?) (body expression?))
  (custom-call-exp (rator expression?) (rand expression?))
)
