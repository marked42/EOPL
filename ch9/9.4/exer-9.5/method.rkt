#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")

(lazy-require
 ["environment.rkt" (extend-env* extend-env-with-self-and-host empty-env)]
 ["store.rkt" (newref)]
 ["object.rkt" (object->fields lookup-class)]
 ["interpreter.rkt" (value-of-exp)]
 )

(provide (all-defined-out))

(define-datatype method method?
  (a-method
   (vars (list-of symbol?))
   (body expression?)
   (host-name symbol?)
   (field-names (list-of symbol?))
   )
  )

(define (apply-method m self args)
  (cases method m
    (a-method (vars body host-name field-names)
              (value-of-exp body
                        (extend-env* vars (map newref args)
                                     (extend-env-with-self-and-host self host-name
                                                                     (extend-env* field-names (object->fields self)
                                                                                  (empty-env)
                                                                                  )
                                                                     )
                                     )
                        )
              )
    )
  )
