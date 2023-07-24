#lang eopl

(require racket/base "../module.rkt" "type.rkt")

(provide (all-defined-out))

(define (rename-in-iface iface old new)
  (cases interface iface
    (simple-interface (decls)
                      (simple-interface (rename-in-decls decls old new))
                      )
    (proc-interface (param-name param-iface result-iface)
                    (proc-interface
                     param-name
                     (rename-in-iface param-iface old new)
                     ; param-name shadows old in result-iface
                     (if (eqv? param-name old)
                         result-iface
                         (rename-in-iface result-iface old new)
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
                (if (eqv? name old) new old)
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


(define (replace-iface iface rator-name rand-iface)
  (cases interface iface
    (simple-interface (decls)
                      (simple-interface (replace-in-decls decls rator-name rand-iface))
                      )
    (proc-interface (param-name param-iface result-iface)
                    (proc-interface
                     param-name
                     (replace-iface param-iface rator-name rand-iface)
                     (replace-iface result-iface rator-name rand-iface)
                     )
                    )
    )
  )

(define (replace-in-decls decls rator-name rand-iface)
  (if (null? decls)
      '()
      (cases declaration (car decls)
        (var-declaration (var-name ty)
                         (cons
                          (var-declaration var-name (replace-in-type ty rator-name rand-iface))
                          (replace-in-decls (cdr decls) rator-name rand-iface)
                          )
                         )
        (opaque-type-declaration (t-name)
                                 (cons
                                  (opaque-type-declaration t-name)
                                  (replace-in-decls (cdr decls) rator-name rand-iface)
                                  )
                                 )
        (transparent-type-declaration (t-name ty)
                                      (cons
                                       (transparent-type-declaration t-name (replace-in-type ty rator-name rand-iface))
                                       (replace-in-decls (cdr decls) rator-name rand-iface)
                                       )
                                      )
        )
      )
  )

(define (replace-in-type ty rator-name rand-iface)
  (cases type ty
    (proc-type (arg-type result-type)
               (proc-type (replace-in-type arg-type rator-name rand-iface) (replace-in-type result-type rator-name rand-iface))
               )
    (qualified-type (m-name t-name)
                    (if (eqv? m-name rator-name)
                        (find-iface-name rand-iface t-name)
                        ty
                        )
                    )
    (else ty)
    )
  )

(define (find-iface-name iface name)
  (cases interface iface
    (simple-interface (decls)
                      (let ([decl (findf (lambda (decl) (eqv? (declaration->name decl) name)) decls)])
                        (if decl
                            (declaration->type decl)
                            (eopl:error 'find-iface-name "No declaration name ~s" name)
                            )
                        )
                      )
    (else (eopl:error 'find-iface-name "Expect simple interface, get ~s" iface))
    )
  )
