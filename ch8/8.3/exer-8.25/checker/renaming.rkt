#lang eopl

(require racket/list "../module.rkt" "type.rkt")

(provide (all-defined-out))

(define (rename-in-iface iface old new)
  (cases interface iface
    (simple-interface (decls)
                      (simple-interface (rename-in-decls decls old new))
                      )
    (proc-interface (param-names param-ifaces result-iface)
                    (proc-interface
                     param-names
                     (map
                      (lambda (param-iface) (rename-in-iface param-iface old new))
                      param-ifaces
                      )
                     ; param-name shadows old in result-iface
                     (rename-in-iface-with-shadow result-iface param-names old new)
                     )
                    )
    )
  )

(define (rename-in-iface-with-shadow iface names old new)
  (let loop ([old-names old] [old old] [new new])
    (if (null? old-names)
        (rename-in-iface iface old new)
        (if (member (car old-names) names)
          (loop (cdr old-names) (cdr old) (cdr new))
          (loop (cdr old-names) old new)
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
                                  (if (member t-name old)
                                      (cdr decls)
                                      (rename-in-decls (cdr decls) old new)
                                      )
                                  )
                                 )
        (transparent-type-declaration (t-name ty)
                                      (cons
                                       (transparent-type-declaration t-name (rename-in-type ty old new))
                                       ; transparent type name shadows old, no need to replace in rest declarations
                                       (if (member t-name old)
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
  (let ([index (index-of old name)])
    (if index (list-ref new index) name)
    )
  )
