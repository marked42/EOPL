#lang eopl

(require "checker/type.rkt")
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
  (proc-exp (var symbol?) (var-type type?) (body expression?))
  (call-exp (rator expression?) (rand expression?))
  (letrec-exp (p-result-type type?) (p-name symbol?) (b-var symbol?) (b-var-type type?) (p-body expression?) (body expression?))

  (newref-exp (exp1 expression?))
  (deref-exp (exp1 expression?))
  (setref-exp (exp1 expression?) (exp2 expression?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
