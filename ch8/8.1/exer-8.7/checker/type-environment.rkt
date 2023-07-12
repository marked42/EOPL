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
  )

(define (apply-tenv env search-var)
  (cases type-environment env
    (extend-tenv (var type saved-env)
                 (if (eqv? search-var var)
                     type
                     (apply-tenv saved-env search-var)
                     )
                 )
    (extend-tenv-with-module (name interface saved-tenv)
                             (if (equal? name search-var)
                                 interface
                                 (apply-tenv saved-tenv search-var)
                                 )
                             )
    (else (eopl:error "Unbound variable ~s" search-var))
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
        )
      )
  )
