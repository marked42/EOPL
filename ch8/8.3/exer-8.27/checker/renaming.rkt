#lang eopl

(require "../module.rkt" "type.rkt")

(provide (all-defined-out))

(define (rename-in-iface iface old new)
  (cases interface iface
    (simple-interface (decls)
                      (simple-interface (rename-in-decls decls old new))
                      )
    (proc-interface (param-name param result-iface)
                    (cases interface-param param
                      (bare-interface-param (iface)
                                            (proc-interface
                                             param-name
                                             (bare-interface-param
                                              (rename-in-iface iface old new)
                                              )
                                             ; param-name shadows old in result-iface
                                             (if (eqv? param-name old)
                                                 result-iface
                                                 (rename-in-iface result-iface old new)
                                                 )
                                             )
                                            )
                      ; invalid state, better get rid of this case by using precise model
                      (named-interface-param (interface-name)
                                             (eopl:error 'rename-in-iface "Expect bare-interface-param, get ~s" param)
                                             )
                      )
                    )
    )
  )

; this isn't a map because we have let* scoping
(define (rename-in-decls decls old new)
  (if (null? decls)
      '()
      (cases declaration (car decls)
        (var-declaration (var-name ty)
                         (cons
                          (var-declaration var-name (rename-in-type ty old new))
                          (rename-in-decls (cdr decls) old new)
                          )
                         )
        (opaque-type-declaration (t-name)
                                 (cons
                                  (opaque-type-declaration t-name)
                                  ; opaque type name shadows old, no need to replace in rest declarations
                                  (if (eqv? t-name old)
                                      (cdr decls)
                                      (rename-in-decls (cdr decls) old new)
                                      )
                                  )
                                 )
        (transparent-type-declaration (t-name ty)
                                      (cons
                                       (transparent-type-declaration t-name (rename-in-type ty old new))
                                       ; transparent type name shadows old, no need to replace in rest declarations
                                       (if (eqv? t-name old)
                                           (cdr decls)
                                           (rename-in-decls (cdr decls) old new)
                                           )
                                       )
                                      )
        )
      )
  )

(define (rename-in-type ty old new)
  (cases type ty
    (proc-type (arg-type result-type)
               (proc-type (rename-in-type arg-type old new) (rename-in-type result-type old new))
               )
    (named-type (name)
                (named-type (rename-name name old new))
                )
    (qualified-type (m-name t-name)
                    (qualified-type (rename-name m-name old new) t-name)
                    )
    (else ty)
    )
  )

(define (rename-name name old new)
  (if (eqv? name old) new old)
  )
