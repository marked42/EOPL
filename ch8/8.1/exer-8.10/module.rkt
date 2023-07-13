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
  (definitions-module-body (import-decl import-declaration?) (definitions (list-of definition?)))
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

(define-datatype import-declaration import-declaration?
  (empty-import-declaration)
  (named-import-declaration (vars (list-of symbol?)))
  )

(define (import-declaration->names decl)
  (cases import-declaration decl
    (empty-import-declaration () '())
    (named-import-declaration (vars) vars)
    )
  )
