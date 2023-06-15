#lang eopl

(provide (all-defined-out))
(require "type.rkt")

(define-datatype type-environment type-environment?
  (empty-tenv)
  (extend-tenv
   (var symbol?)
   (type type?)
   (tenv type-environment?)
   )
  )

(define (init-tenv)
  (extend-tenv 'i (int-type)
               (extend-tenv 'v (int-type)
                            (extend-tenv 'x (int-type)
                                         (empty-tenv)
                                         )
                            )
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
