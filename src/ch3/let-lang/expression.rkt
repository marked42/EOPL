#lang eopl

(provide (all-defined-out))

(define identifier? symbol?)

(define-datatype expression expression?
  (const-exp
   (num number?)
   )
  (diff-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (sum-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (mul-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (div-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (equal?-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (greater?-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (less?-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (minus-exp
   (exp1 expression?)
   )
  (zero?-exp
   (exp1 expression?)
   )
  (if-exp
   (exp1 expression?)
   (exp2 expression?)
   (exp3 expression?)
   )
  (var-exp
   (var identifier?)
   )
  (let-exp
   (var identifier?)
   (exp1 expression?)
   (body expression?)
   )

  (emptylist-exp)
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
