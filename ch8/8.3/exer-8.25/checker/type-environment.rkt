#lang eopl

(require racket/list "type.rkt" "../module.rkt")

(provide (all-defined-out))

(define-datatype type-environment type-environment?
  (empty-tenv)
  (extend-tenv
   (var symbol?)
   (type type?)
   (saved-tenv type-environment?)
   )
  (extend-tenv-with-module
   (names (list-of symbol?))
   (ifaces (list-of interface?))
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
      (proc-interface (param-name param-iface result-iface)
                      (eopl:error 'lookup-qualified-type-in-tenv "proc-interface ~s" iface)
                      )
      )
    )
  )

(define (lookup-module-name-in-tenv tenv m-name)
  (cases type-environment tenv
    (extend-tenv (var type saved-tenv)
                 (lookup-module-name-in-tenv saved-tenv m-name)
                 )
    (extend-tenv-with-module (names ifaces saved-tenv)
                             (let ([index (index-of names m-name)])
                               (if index
                                   (list-ref ifaces index)
                                   (lookup-module-name-in-tenv saved-tenv m-name)
                                   )
                               )
                             )
    (extend-tenv-with-type (name ty saved-tenv)
                           (lookup-module-name-in-tenv saved-tenv m-name)
                           )
    (empty-tenv () (eopl:error 'lookup-module-name-in-tenv "fail to find module ~s " m-name))
    )
  )

(define (lookup-variable-name-in-declarations var-name declarations)
  (if (null? declarations)
      #f
      (cases declaration (car declarations)
        (var-declaration (this-var-name ty)
                         (if (eqv? var-name this-var-name)
                             ty
                             (lookup-variable-name-in-declarations var-name (cdr declarations))
                             )
                         )
        (opaque-type-declaration (this-var-name)
                                 (eopl:error 'lookup-variable-name-in-declarations "can't take type of abstract type declaration ~s" (car declarations))
                                 )
        (transparent-type-declaration (this-var-name ty)
                                      (if (eqv? var-name this-var-name)
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
    (extend-tenv-with-module (m-names ifaces saved-tenv)
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
