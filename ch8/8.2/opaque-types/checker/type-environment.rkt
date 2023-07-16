#lang eopl

(provide (all-defined-out))
(require "type.rkt" "../module.rkt")

(define-datatype type-environment type-environment?
  (empty-tenv)
  (extend-tenv
   (var symbol?)
   (type type?)
   (saved-tenv type-environment?)
   )
  (extend-tenv-with-module
   (name symbol?)
   (interface interface?)
   (saved-tenv type-environment?)
   )
  (extend-tenv-with-type
   (name symbol?)
   (ty type?)
   (saved-tenv type-environment?)
  )
  )

(define (apply-tenv env search-var)
  (cases type-environment env
    (extend-tenv (var type saved-tenv)
                 (if (eqv? search-var var)
                     type
                     (apply-tenv saved-tenv search-var)
                     )
                 )
    (else (eopl:error "Unbound variable ~s" search-var))
    )
  )

(define (lookup-qualified-type-in-tenv m-name var-name tenv)
  (let ([iface (lookup-module-name-in-tenv tenv m-name)])
    (cases interface iface
      (simple-interface (declarations)
                        (lookup-variable-name-in-declarations var-name declarations)
                        )
      )
    )
  )

(define (lookup-module-name-in-tenv tenv m-name)
  (cases type-environment tenv
    (extend-tenv (var type saved-tenv)
                 (lookup-module-name-in-tenv saved-tenv m-name)
                 )
    (extend-tenv-with-module (name iface saved-tenv)
                             (if (equal? name m-name)
                                 iface
                                 (lookup-module-name-in-tenv saved-tenv m-name)
                                 )
                             )
    (extend-tenv-with-type (name ty saved-tenv)
                           (lookup-module-name-in-tenv saved-tenv m-name)
                           )
    (empty-tenv () (eopl:error 'lookup-module-name-in-tenv "fail to find module ~s" m-name))
    )
  )

(define (lookup-variable-name-in-declarations var-name declarations)
  (if (null? declarations)
      #f
      (cases declaration (car declarations)
        (var-declaration (this-var-name ty)
                         (if (equal? var-name this-var-name)
                             ty
                             (lookup-variable-name-in-declarations var-name (cdr declarations))
                             )
                         )
        (opaque-type-declaration (this-var-name)
                                 ; TODO:
                                 (eopl:error 'lookup-variable-name-in-declarations "can't take type of abstract type declaration ~s" (car declarations))
                                 )
        (transparent-type-declaration (this-var-name ty)
                                      (if (equal? var-name this-var-name)
                                        ty
                                        (lookup-variable-name-in-declarations var-name (cdr declarations))
                                        )
                                      )
        )
      )
  )

(define (lookup-type-name-in-tenv name tenv)
  (cases type-environment tenv
    (extend-tenv (var ty saved-tenv)
                 (lookup-type-name-in-tenv name saved-tenv)
                 )
    (extend-tenv-with-module (m-name interface saved-tenv)
                             (lookup-type-name-in-tenv name saved-tenv)
                             )
    (extend-tenv-with-type (t-name ty saved-tenv)
                           (if (eqv? t-name name)
                            ty
                            (lookup-type-name-in-tenv name saved-tenv)
                           )
                          )
    (empty-tenv () (eopl:error 'lookup-type-name-in-tenv "fail to find type ~s" name))
  )
)
