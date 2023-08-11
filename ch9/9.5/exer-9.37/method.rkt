#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")

(lazy-require
 ["environment.rkt" (extend-env* extend-env-with-self-and-super empty-env)]
 ["store.rkt" (newref)]
 ["object.rkt" (object->fields lookup-class)]
 ["interpreter.rkt" (value-of-exp)]
 ["checker/type.rkt" (void-type)]
 )

(provide (all-defined-out))

(define-datatype method method?
  (a-method
   (vars (list-of symbol?))
   (body expression?)
   (super-name symbol?)
   (field-names (list-of symbol?))
   (is-static boolean?)
   )
  )

(define (apply-method m self args)
  (cases method m
    (a-method (vars body super-name field-names is-static)
              (value-of-exp body
                            (extend-env* vars
                                         (map newref args)
                                         ; use void type as stub for method parameter type, never used
                                         (map (lambda (name) (void-type)) vars)
                                         (extend-env-with-self-and-super self super-name
                                                                         (extend-env*
                                                                          field-names
                                                                          (object->fields self)
                                                                          ; use void type as stub for field type, never used
                                                                          (map (lambda (name) (void-type)) field-names)
                                                                          (empty-env)
                                                                          )
                                                                         )
                                         )
                            )
              )
    )
  )

(define (is-static-method? m)
  (cases method m
    (a-method (vars body super-name field-names is-static) is-static)
    )
  )
