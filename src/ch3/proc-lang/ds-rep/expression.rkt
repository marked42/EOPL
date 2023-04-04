#lang eopl

(require racket/lazy-require "basic.rkt")
(lazy-require ["value.rkt" (num-val)])

(provide (all-defined-out))

(define-datatype expression expression?
  (const-exp
   (num number?)
   )
  (diff-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (sum-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (mul-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (div-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (equal?-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (greater?-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (less?-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (minus-exp
   (exp1 expression?)
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
  (let*-exp
   (vars (list-of identifier?))
   (exps (list-of expression?))
   (body expression?)
   )
  (unpack-exp
   (vars (list-of identifier?))
   (exp expression?)
   (body expression?)
   )

  (cons-exp
   (exp1 expression?)
   (exp2 expression?)
   )
  (car-exp
   (exp1 expression?)
   )
  (cdr-exp
   (exp1 expression?)
   )
  (emptylist-exp)
  (null?-exp
   (exp1 expression?)
   )
  (list-exp
   (exp1 expression?)
   (exps (list-of expression?))
   )

  (cond-exp
   (conds (list-of expression?))
   (acts (list-of expression?))
   )

  (print-exp
   (exp1 expression?)
   )

  (proc-exp (first-var identifier?) (rest-vars (list-of identifier?)) (body expression?))
  (traceproc-exp (first-var identifier?) (rest-vars (list-of identifier?)) (body expression?))
  (letproc-exp (proc-name identifier?) (name identifier?) (proc-body expression?) (body expression?))
  (call-exp (rator expression?) (rands (list-of expression?)))
  )

(define-datatype program program?
  (a-program
   (exp1 expression?)
   )
  )
