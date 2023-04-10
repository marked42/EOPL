#lang eopl

(require racket/lazy-require "basic.rkt")

(provide (all-defined-out))

(define-datatype expression expression?
  (const-exp
   (num number?)
   )
  (diff-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (zero?-exp
   (exp1 expression?)
   )
  (if-exp
   (exp1 expression?)
   (exp2 expression?)
   (exp3 expression?)
   )
  (var-exp
   (var identifier?)
   )
  (let-exp
   (vars (list-of identifier?))
   (exps (list-of expression?))
   (body expression?)
   )
  (letrec-exp
   (p-names (list-of identifier?))
   (b-vars (list-of (list-of identifier?)))
   (p-bodies (list-of expression?))
   (body expression?)
   )
  (proc-exp (first-var identifier?) (rest-vars (list-of identifier?)) (body expression?))
  (call-exp (rator expression?) (rands (list-of expression?)))

  (begin-exp (first expression?) (others (list-of expression?)))
  (assign-exp (var identifier?) (exp1 expression?))

  ; mut-pair
  (newpair-exp (left expression?) (right expression?))
  (left-exp (exp1 expression?))
  (right-exp (exp1 expression?))
  (setleft-exp (exp1 expression?) (exp2 expression?))
  (setright-exp (exp1 expression?) (exp2 expression?))

  (newarray-exp (len expression?) (val expression?))
  (arrayref-exp (arr expression?) (index expression?))
  (arrayset-exp (arr expression?) (index expression?) (value expression?))
  (arraylength-exp (arr expression?))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
