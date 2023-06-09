#lang eopl

(require "checker/type.rkt" "typed-var.rkt")
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
  (proc-exp (typed-vars (list-of typed-var?)) (body expression?))
  (call-exp (rator expression?) (rand (list-of expression?)))
  (letrec-exp (p-result-types (list-of type?)) (p-names (list-of symbol?)) (b-typed-vars-list (list-of (list-of typed-var?))) (p-bodies (list-of expression?)) (body expression?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
