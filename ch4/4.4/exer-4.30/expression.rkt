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
  (proc-exp (var symbol?) (body expression?))
  (call-exp (rator expression?) (rand expression?))
  (letrec-exp (p-names (list-of symbol?)) (b-vars (list-of symbol?)) (p-bodies (list-of expression?)) (body expression?))

  (begin-exp (exp1 expression?) (exps (list-of expression?)))

  (assign-exp (var symbol?) (exp1 expression?))

  ; new stuff
  (newarray-exp (exp1 expression?) (exp2 expression?))
  (arrayref-exp (exp1 expression?) (exp2 expression?))
  (arrayset-exp (exp1 expression?) (exp2 expression?) (exp3 expression?))
  (arraylength-exp (exp1 expression?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
