#lang eopl

(require racket/list racket/lazy-require "checker/type.rkt")
(lazy-require
 ["environment.rkt" (environment? apply-env)]
 ["expression.rkt" (expression?)]
 ["checker/type.rkt" (type?)]
 ["value.rkt" (expval->module)]
 )

(provide (all-defined-out))

(define-datatype typed-module typed-module?
  (simple-module (bindings environment?))
  )

(define-datatype module-definition module-definition?
  (a-module-definition (m-name symbol?) (expected-interface interface?) (m-body module-body?))
  )

(define-datatype module-body module-body?
  (definitions-module-body (modules (list-of module-definition?)) (definitions (list-of definition?)))
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

(define (get-qualified-var-mod val var-names)
  (if (null? var-names)
      val
      (let ([mod (expval->module val)])
        (cases typed-module mod
          (simple-module (bindings)
                         (get-qualified-var-mod
                          (apply-env bindings (car var-names))
                          (cdr var-names)
                          )
                         )
          )
        )
      )
  )

(define (get-qualified-var-type ty var-names)
  (if (null? var-names)
      ty
      (cases type ty
        (module-type (vars types)
                     (let ([index (index-of vars (car var-names))])
                       (get-qualified-var-mod
                        (list-ref types index)
                        (cdr var-names)
                        )
                       )
                     )
        (else (eopl:error 'get-qualified-var-type "Expecte a module-type, get ~s" ty))
        )
      )
  )
