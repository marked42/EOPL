#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")

(lazy-require
 ["environment.rkt" (extend-env* extend-env-with-self-and-super empty-env)]
 ["store.rkt" (newref)]
 ["object.rkt" (object->fields lookup-class)]
 ["interpreter.rkt" (value-of-exp)]
 )

(provide (all-defined-out))

(define-datatype method method?
  (a-method
   (host-class-name symbol?)
   (vars (list-of symbol?))
   (body expression?)
   (super-name symbol?)
   (field-names (list-of symbol?))
   )
  )

(define (apply-method m self args)
  (cases method m
    (a-method (host-class-name vars body super-name field-names)
              (value-of-exp body
                            (extend-env* vars (map newref args)
                                         (extend-env-with-self-and-super self host-class-name super-name
                                                                         (extend-env* field-names (object->fields self)
                                                                                      (empty-env)
                                                                                      )
                                                                         )
                                         )
                            )
              )
    )
  )
