#lang eopl

(require "../../../base/basic.rkt")

(provide (all-defined-out))

(define-datatype cps-program cps-program?
  (cps-a-program
   (exp1 tfexp?)
   )
  )

(define-datatype simple-expression simple-expression?
  (cps-const-exp (num number?))
  (cps-var-exp (var identifier?))
  (cps-diff-exp (exp1 simple-expression?) (exp2 simple-expression?))
  (cps-zero?-exp (exp1 simple-expression?))
  (cps-proc-exp (vars (list-of identifier?)) (body tfexp?))
  (cps-sum-exp (exps (list-of simple-expression?)))
  )

(define-datatype tfexp tfexp?
  (simple-exp->exp (exp1 simple-expression?))
  (cps-let-exp (var identifier?) (exp1 simple-expression?) (body tfexp?))
  (cps-letrec-exp
   (p-names (list-of identifier?))
   (b-varss (list-of (list-of identifier?)))
   (p-bodies (list-of tfexp?))
   (body tfexp?)
   )
  (cps-if-exp (exp1 simple-expression?) (exp2 tfexp?) (exp3 tfexp?))
  (cps-call-exp (rator simple-expression?) (rands (list-of simple-expression?)))
  )
