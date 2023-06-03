#lang eopl

(require racket/lazy-require "basic.rkt")
(lazy-require ["value.rkt" (num-val)])

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
   (p-name identifier?)
   (b-var identifier?)
   (p-body expression?)
   (body expression?)
   )
  (proc-exp (var identifier?) (body expression?))
  (call-exp (rator expression?) (rand expression?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
