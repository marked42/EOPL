#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")

(lazy-require
 ["environment.rkt" (extend-env* extend-env-method* extend-env-with-self-and-super empty-env)]
 ["store.rkt" (newref)]
 ["object.rkt" (object->fields lookup-class)]
 ["interpreter.rkt" (value-of-exp)]
 ["modifier.rkt" (visibility-modifier?)]
 )

(provide (all-defined-out))

(define-datatype method method?
  (a-method
   (modifier? visibility-modifier?)
   (vars (list-of symbol?))
   (body expression?)
   (super-name symbol?)
   (field-names (list-of symbol?))
   )
  )

(define (apply-method class-name method-name m self args)
  (cases method m
    (a-method (modifier vars body super-name field-names)
              (value-of-exp body
                            (extend-env-method* class-name method-name vars (map newref args)
                                                (extend-env-with-self-and-super self super-name
                                                                                (extend-env* field-names (object->fields self)
                                                                                             (empty-env)
                                                                                             )
                                                                                )
                                                )
                            )
              )
    )
  )

(define (method->modifier m)
  (cases method m
    (a-method (modifier vars body super-name field-names) modifier)
    )
  )
