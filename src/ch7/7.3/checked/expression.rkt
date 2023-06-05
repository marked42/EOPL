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
   (var identifier?)
   (exp1 expression?)
   (body expression?)
   )
  (letrec-exp
   (p-result-type type?)
   (p-name identifier?)
   (b-var identifier?)
   (b-var-type type?)
   (p-body expression?)
   (body expression?)
   )
  (proc-exp (var identifier?) (var-type type?) (body expression?))
  (call-exp (rator expression?) (rand expression?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
