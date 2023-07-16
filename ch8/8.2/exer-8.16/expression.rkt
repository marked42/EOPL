#lang eopl

(require "checker/type.rkt" "typed-var.rkt" "module.rkt")
(provide (all-defined-out))

(define-datatype program program?
  (a-program
   (m-defs (list-of module-definition?))
   (body expression?)
   )
  )

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
  (proc-exp (typed-var (list-of typed-var?)) (body expression?))
  (call-exp (rator expression?) (rand (list-of expression?)))
  (letrec-exp (p-result-type type?) (p-name symbol?) (b-typed-var typed-var?) (p-body expression?) (body expression?))
  (qualified-var-exp (m-name symbol?) (var-name symbol?))
  )
