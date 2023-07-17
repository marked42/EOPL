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
  )

(define-datatype interface interface?
  (simple-interface (declarations (list-of declaration?)))
  )

(define-datatype declaration declaration?
  (var-declaration (var-name symbol?) (ty type?))
  (opaque-type-declaration (t-name symbol?))
  (transparent-type-declaration (t-name symbol?) (ty type?))
  )

(define-datatype definition definition?
  (val-definition (var-name symbol?) (exp expression?))
  (type-definition (var-name symbol?) (ty type?))
  )

(define (var-declaration? decl)
  (cases declaration decl
    (var-declaration (var-name ty) #t)
    (else #f)
    )
  )

(define (transparent-type-declaration? decl)
  (cases declaration decl
    (transparent-type-declaration (t-name ty) #t)
    (else #f)
    )
  )

(define (opaque-type-declaration? decl)
  (cases declaration decl
    (opaque-type-declaration (t-name) #t)
    (else #f)
    )
  )

(define (declaration->name decl)
  (cases declaration decl
    (var-declaration (var-name ty)
                     var-name
                     )
    (opaque-type-declaration (name) name)
    (transparent-type-declaration (t-name ty) t-name)
    )
  )

(define (declaration->type decl)
  (cases declaration decl
    (var-declaration (var-name ty)
                     ty
                     )
    (opaque-type-declaration (name) name)
    (transparent-type-declaration (t-name ty) ty)
    (opaque-type-declaration (eopl:error 'declaration->type "Can't take the type of abstract type declaration ~s" decl))
    )
  )
