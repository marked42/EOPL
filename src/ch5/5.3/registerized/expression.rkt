#lang eopl

(require racket/lazy-require "basic.rkt")

(provide (all-defined-out))

(define-datatype expression expression?
  (const-exp (num number?))
  (diff-exp (exp1 expression?) (exp2 expression?))
  (zero?-exp (exp1 expression?))
  (if-exp (exp1 expression?) (exp2 expression?) (exp3 expression?))
  (var-exp (var1 identifier?))
  (let-exp (var1 identifier?) (exp1 expression?) (body expression?))
  (proc-exp (var1 identifier?) (body expression?))
  (call-exp (rator expression?) (rand expression?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
