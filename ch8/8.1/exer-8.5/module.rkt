#lang eopl

(require racket/lazy-require)
(lazy-require
 ["environment.rkt" (environment?)]
 ["expression.rkt" (expression?)]
 ["checker/type.rkt" (type?)]
 )

(provide (all-defined-out))

(define-datatype typed-module typed-module?
  (simple-module (bindings environment?))
  )

(define-datatype module-definition module-definition?
  (a-module-definition (m-name symbol?) (expected-interface interface?) (m-body module-body?))
  )

(define-datatype module-body module-body?
  (definitions-module-body (definitions (list-of definition?)))
  (letrec-module-body
   (p-result-types (list-of type?))
   (p-names (list-of symbol?))
   (b-vars (list-of symbol?))
   (b-var-types (list-of type?))
   (p-bodies (list-of expression?))
   (definitions (list-of definition?))
   )
  )

(define-datatype interface interface?
  (simple-interface (declarations (list-of declaration?)))
  )

(define-datatype declaration declaration?
  (var-declaration (var-name symbol?) (ty type?))
  )

(define-datatype definition definition?
  (val-definition (var-name symbol?) (exp expression?))
  )

(define (decl->name decl)
  (cases declaration decl
    (var-declaration (var-name ty)
                     var-name
                     )
    )
  )

(define (decl->type decl)
  (cases declaration decl
    (var-declaration (var-name ty)
                     ty
                     )
    )
  )
