#lang eopl

(require racket/lazy-require "basic.rkt")
(lazy-require ["grammar.rkt" (type?)])

(provide (all-defined-out))

(define-datatype expression expression?
  (const-exp (num number?))
  (var-exp (var identifier?))
  (diff-exp (exp1 expression?) (exp2 expression?))
  (zero?-exp (exp1 expression?))
  (if-exp (exp1 expression?) (exp2 expression?) (exp3 expression?))
  (let-exp
   (vars (list-of identifier?))
   (exps (list-of expression?))
   (body expression?)
   )
  (letrec-exp
   (p-result-type type?)
   (p-name identifier?)
   (b-vars (list-of identifier?))
   (b-var-types (list-of type?))
   (p-body expression?)
   (body expression?)
   )
  (proc-exp (vars (list-of identifier?)) (var-types (list-of type?)) (body expression?))
  (call-exp (rator expression?) (rands (list-of expression?)))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
