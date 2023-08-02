#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")

(lazy-require
 ["environment.rkt" (extend-env* extend-env-with-self-and-super empty-env)]
 ["store.rkt" (newref reference?)]
 ["object.rkt" (object->fields lookup-class)]
 ["interpreter.rkt" (value-of-exp)]
 ["pair-of.rkt" (pair-of)]
 )

(provide (all-defined-out))

(define-datatype method method?
  (a-method
   (vars (list-of symbol?))
   (body expression?)
   (super-name symbol?)
   (field-names (list-of symbol?))
   (static-class-fields (list-of (pair-of symbol? reference?)))
   )
  )

(define (apply-method m self args)
  (cases method m
    (a-method (vars body super-name field-names class-static-fields)
              (value-of-exp
               body
               (extend-env*
                vars (map newref args)
                (extend-env-with-self-and-super
                 self
                 super-name
                 (extend-env*
                  field-names
                  (object->fields self)
                  (extend-env*
                   (map car class-static-fields)
                   (map cdr class-static-fields)
                   (empty-env)
                   )
                  )
                 )
                )
               )
              )
    )
  )
