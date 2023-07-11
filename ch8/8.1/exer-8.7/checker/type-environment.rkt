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
    (else (eopl:error "Unbound variable ~s" search-var))
    )
  )

(define (lookup-qualified-var-in-tenv m-name var-name tenv)
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
        )
      )
  )
