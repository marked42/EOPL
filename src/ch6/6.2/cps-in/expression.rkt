#lang eopl

(require "basic.rkt")

(provide (all-defined-out))

(define-datatype expression expression?
  (const-exp (num number?))
  (var-exp (var1 identifier?))

  (diff-exp (exp1 expression?) (exp2 expression?))
  (zero?-exp (exp1 expression?))

  (if-exp (exp1 expression?) (exp2 expression?) (exp3 expression?))

  (proc-exp (vars (list-of identifier?)) (body expression?))
  (call-exp (rator expression?) (rands (list-of expression?)))

  (sum-exp (exps (list-of expression?)))

  (let-exp (var1 identifier?) (exp1 expression?) (body expression?))
  (letrec-exp
   (p-names (list-of identifier?))
   (b-varss (list-of (list-of identifier?)))
   (p-bodies (list-of expression?))
   (body expression?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
