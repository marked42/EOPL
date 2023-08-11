#lang eopl

(require racket/lazy-require)
(lazy-require
 ["checker/type.rkt" (type?)]
 )

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
  (proc-exp (vars (list-of symbol?)) (types (list-of type?)) (body expression?))
  (call-exp (rator expression?) (rands (list-of expression?)))
  (letrec-exp
   (p-result-types (list-of type?))
   (p-names (list-of symbol?))
   (b-vars-list (list-of (list-of symbol?)))
   (b-var-types-list (list-of (list-of type?)))
   (p-bodies (list-of expression?))
   (body expression?))

  (begin-exp (exp1 expression?) (exps (list-of expression?)))

  (assign-exp (var symbol?) (exp1 expression?))

  (cons-exp (exp1 expression?) (exp2 expression?))
  (car-exp (exp1 expression?))
  (cdr-exp (exp1 expression?))
  (emptylist-exp (element-type type?))
  (null?-exp (exp1 expression?))
  (list-exp (exp1 expression?) (exps (list-of expression?)))

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

  (cast-exp (obj-exp expression?) (class-name symbol?))
  (instanceof-exp (obj-exp expression?) (class-name symbol?))
  )

(define-datatype class-decl class-decl?
  (a-class-decl
   (class-name symbol?)
   (super-parent symbol?)
   (interface-names (list-of symbol?))
   (field-types (list-of type?))
   (field-names (list-of symbol?))
   (method-decls (list-of method-decl?))
   )
  (an-interface-decl
   (name symbol?)
   (super-interfaces (list-of symbol?))
   (method-decls (list-of method-decl?))
   )
  )

(define-datatype method-decl method-decl?
  (a-method-decl
   (res-type type?)
   (method-name symbol?)
   (vars (list-of symbol?))
   (var-types (list-of type?))
   (body expression?)
   )
  (an-abstract-method-decl
   (res-type type?)
   (method-name symbol?)
   (vars (list-of symbol?))
   (var-types (list-of type?))
   )
  )

(define-datatype program program?
  (a-program
   (class-decls (list-of class-decl?))
   (exp1 expression?)
   )
  )
