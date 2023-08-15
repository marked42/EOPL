#lang eopl

(provide (all-defined-out))

(define-datatype expression expression?
  (const-exp (num number?))
  (var-exp (var symbol?))
  (diff-exp (exp1 expression?) (exp2 expression?))
  (sum-exp (exp1 expression?) (exp2 expression?))
  (zero?-exp (exp1 expression?))
  (if-exp (exp1 expression?) (exp2 expression?) (exp3 expression?))
  (let-exp
   (vars (list-of symbol?))
   (exps (list-of expression?))
   (body expression?)
   )
  (proc-exp (vars (list-of symbol?)) (body expression?))
  (call-exp (rator expression?) (rands (list-of expression?)))
  (letrec-exp (p-names (list-of symbol?)) (b-vars (list-of symbol?)) (p-bodies (list-of expression?)) (body expression?))

  (begin-exp (exp1 expression?) (exps (list-of expression?)))

  (assign-exp (var symbol?) (exp1 expression?))

  (cons-exp (exp1 expression?) (exp2 expression?))
  (car-exp (exp1 expression?))
  (cdr-exp (exp1 expression?))
  (emptylist-exp)
  (null?-exp (exp1 expression?))
  (list-exp (exps (list-of expression?)))

  (new-object-exp
   (class-name symbol?)
   (rands (list-of expression?))
   )
  (method-call-exp
   (obj-exp expression?)
   (method-name symbol?)
   (rands (list-of expression?))
   )
  (super-call-exp
   (method-name symbol?)
   (rands (list-of expression?))
   )
  (self-exp)

  (nameless-var-exp (depth integer?) (position integer?))
  (nameless-let-exp (exps (list-of expression?)) (body expression?))
  (nameless-proc-exp (body expression?))

  (nameless-assign-exp (depth integer?) (offset integer?) (exp1 expression?))
  )

(define-datatype class-decl class-decl?
  (a-class-decl
   (class-name symbol?)
   (super-parent symbol?)
   (field-names (list-of symbol?))
   (method-decls (list-of method-decl?))
   )
  )

(define-datatype method-decl method-decl?
  (a-method-decl
   (method-name symbol?)
   (vars (list-of symbol?))
   (body expression?)
   )
  )

(define-datatype program program?
  (a-program
   (class-decls (list-of class-decl?))
   (exp1 expression?)
   )
  )
