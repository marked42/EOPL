#lang eopl

(require "inferrer/type.rkt" "typed-var.rkt")
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
  (proc-exp (typed-var (list-of typed-var?)) (body expression?))
  (call-exp (rator expression?) (rand (list-of expression?)))
  (letrec-exp
    (p-result-otype-list (list-of optional-type?))
    (p-names (list-of symbol?))
    (b-typed-vars (list-of typed-var?))
    (p-bodies (list-of expression?))
    (body expression?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
