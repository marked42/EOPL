#lang eopl

(provide (all-defined-out))

(define-datatype expression expression?
  (const-exp (num number?))
  (var-exp (var symbol?))
  (diff-exp (exp1 expression?) (exp2 expression?))
  (if-exp (exp1 bool-exp?) (exp2 expression?) (exp3 expression?))
  (let-exp
   (var symbol?)
   (exp1 expression?)
   (body expression?)
   )

  ; new stuff
  (top-level-bool-exp (exp1 bool-exp?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )

; new stuff
(define-datatype bool-exp bool-exp?
  (zero?-exp (exp1 expression?))
  (equal?-exp (exp1 expression?) (exp2 expression?))
  (greater?-exp (exp1 expression?) (exp2 expression?))
  (less?-exp (exp1 expression?) (exp2 expression?))
)
