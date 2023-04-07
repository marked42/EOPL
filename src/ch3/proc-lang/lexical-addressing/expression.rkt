#lang eopl

(provide (all-defined-out))
(require "basic.rkt")

(define-datatype expression expression?
  (const-exp (num number?))
  (diff-exp (exp1 expression?) (exp2 expression?))
  (zero?-exp (exp1 expression?))
  (if-exp (exp1 expression?) (exp2 expression?) (exp3 expression?))
  (var-exp (var identifier?))
  ; environment frame
  (nameless-var-exp (var pair?))

  (let-exp (vars (list-of identifier?)) (exp (list-of expression?)) (body expression?))
  ; get rid of var compared to let-exp
  (nameless-let-exp (exps (list-of expression?)) (body expression?))

  (proc-exp (names (list-of identifier?)) (body expression?))
  ; get rid of name
  (nameless-proc-exp (body expression?))

  (call-exp (rator expression?) (rands (list-of expression?)))

  (cond-exp (conds (list-of expression?)) (acts (list-of expression?)))

  (letrec-exp (p-name identifier?) (b-var identifier?) (p-body expression?) (body expression?))
  (nameless-letrec-exp (p-body expression?) (body expression?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )