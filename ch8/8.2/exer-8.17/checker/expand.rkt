#lang eopl

(require "type-environment.rkt" "type.rkt" "../module.rkt")

(provide (all-defined-out))

(define (expand-type ty tenv)
  (cases type ty
    (int-type () (int-type))
    (bool-type () (bool-type))
    (proc-type (arg-type result-type)
               (proc-type (expand-type arg-type tenv) (expand-type result-type tenv))
               )
    (named-type (name)
                (lookup-type-name-in-tenv name tenv)
                )
    (qualified-type (m-name t-name)
                    (lookup-qualified-type-in-tenv m-name t-name tenv)
                    )
    )
  )

(define (expand-iface m-name iface tenv)
  (cases interface iface
    (simple-interface (declarations)
                      (simple-interface (expand-declarations m-name declarations tenv))
                      )
    )
  )

(define (expand-declarations m-name declarations tenv)
  (if (null? declarations)
      '()
      (cases declaration (car declarations)
        (opaque-type-declaration (t-name)
                                 (let* ([expanded-type (qualified-type m-name t-name)]
                                        [new-tenv (extend-tenv-with-type t-name expanded-type tenv)])
                                   (cons
                                    (transparent-type-declaration t-name expanded-type)
                                    (expand-declarations m-name (cdr declarations) new-tenv)
                                    )
                                   )
                                 )
        (transparent-type-declaration (t-name ty)
                                      (let* ([expanded-type (expand-type ty tenv)]
                                             [new-tenv (extend-tenv-with-type t-name expanded-type tenv)])
                                        (cons
                                         (transparent-type-declaration t-name expanded-type)
                                         (expand-declarations m-name (cdr declarations) new-tenv)
                                         )
                                        )
                                      )
        (var-declaration (var-name ty)
                         (let* ([expanded-type (expand-type ty tenv)])
                           (cons
                            (var-declaration var-name expanded-type)
                            (expand-declarations m-name (cdr declarations) tenv)
                            )
                           )
                         )
        )
      )
  )

(define (extend-tenv-with-declaration decl tenv)
  (cases declaration decl
    (var-declaration (var-name ty) tenv)
    (transparent-type-declaration (name ty)
                                  (extend-tenv-with-type name (expand-type ty tenv) tenv)
                                  )
    (opaque-type-declaration (name)
                             ; code different from the book
                             (eopl:error 'extend-tenv-with-declaration "expanded iface contains no opaque-type-declaration ~s" decl)
                             ; (extend-tenv-with-type name (qualified-type (fresh-module-name '%unknown name)) tenv)
                             )
    )
  )


(define sn 0)
(define (fresh-module-name module-name)
  (set! sn (+ sn 1))
  (string->symbol
   (string-append
    (symbol->string module-name)
    "%"             ; this can't appear in an input identifier
    (number->string sn)))
  )
