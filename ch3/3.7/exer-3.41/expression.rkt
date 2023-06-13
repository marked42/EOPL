#lang eopl

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
  (proc-exp (var (list-of symbol?)) (body expression?))
  (call-exp (rator expression?) (rands (list-of expression?)))

  ; new stuff
  (nameless-var-exp (depth integer?) (position integer?))
  (nameless-let-exp (exps (list-of expression?)) (body expression?))
  (nameless-proc-exp (body expression?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
