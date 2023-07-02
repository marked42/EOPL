#lang eopl

(require "type.rkt" racket/list)

(provide (all-defined-out))

(define-datatype type-environment type-environment?
  (empty-tenv)
  (extend-tenv*
   (vars (list-of symbol?))
   (type (list-of type?))
   (tenv type-environment?)
   )
  )

(define (init-tenv)
  (extend-tenv* '(i v x)
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
