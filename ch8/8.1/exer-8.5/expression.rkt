#lang eopl

(require "checker/type.rkt" "module.rkt")
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
  (proc-exp (params (list-of parameter?)) (body expression?))
  (call-exp (rator expression?) (rands (list-of expression?)))
  (letrec-exp
   (p-result-types (list-of type?))
   (p-names (list-of symbol?))
   (b-vars (list-of symbol?))
   (b-var-types (list-of type?))
   (p-body (list-of expression?))
   (body expression?))

  (qualified-var-exp (m-name symbol?) (var-name symbol?))
  )

(define-datatype parameter parameter?
  (typed-parameter (var symbol?) (ty type?))
  )

(define (parameter->var p)
  (cases parameter p
    (typed-parameter (var ty) var)
    )
  )

(define (parameter->type p)
  (cases parameter p
    (typed-parameter (var ty) ty)
    )
  )
