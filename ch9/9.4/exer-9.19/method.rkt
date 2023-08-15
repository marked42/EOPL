#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")

(lazy-require
 ["environment.rkt" (extend-nameless-env empty-nameless-env)]
 ["store.rkt" (newref)]
 ["object.rkt" (object->fields lookup-class)]
 ["interpreter.rkt" (value-of-exp)]
 )

(provide (all-defined-out))

(define-datatype method method?
  (a-method
   (vars (list-of symbol?))
   (body expression?)
   (super-name symbol?)
   (field-names (list-of symbol?))
   )
  )

(define self-index '(1 0))
(define super-index '(1 1))

(define (apply-method m self args)
  (cases method m
    (a-method (vars body super-name field-names)
              (value-of-exp body
                            (extend-nameless-env (map newref args)
                                                 (extend-nameless-env (list self super-name)
                                                                      (extend-nameless-env (object->fields self)
                                                                                          (empty-nameless-env)
                                                                                          )
                                                                      )
                                                 )
                            )
              )
    )
  )
