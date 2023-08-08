#lang eopl

(provide (all-defined-out))
(require "type.rkt" racket/list)

(define-datatype type-environment type-environment?
  (empty-tenv)
  (extend-tenv*
   (vars (list-of symbol?))
   (types (list-of type?))
   (tenv type-environment?)
   )
  )

(define (init-tenv)
  (extend-tenv*
   (list 'i 'x 'v)
   (list (int-type) (int-type) (int-type))
   (empty-tenv)
   )
  )

(define (apply-tenv env search-var)
  (cases type-environment env
    (extend-tenv* (vars types saved-env)
                  (let ([index (index-of vars search-var)])
                    (if index
                        (list-ref types index)
                        (apply-tenv saved-env search-var)
                        )
                    )
                  )
    (else (eopl:error "Unbound variable ~s" search-var))
    )
  )
