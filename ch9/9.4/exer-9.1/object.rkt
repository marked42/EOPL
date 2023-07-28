#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")

(lazy-require
 ["store.rkt" (reference? newref)]
 ["class.rkt" (class->field-names lookup-class)]
 )

(provide (all-defined-out))

(define-datatype object object?
    (an-object (class-name symbol?) (fields (list-of reference?)))
)

(define (object->class-name obj)
    (cases object obj
        (an-object (class-name fields) class-name)
    )
)

(define (object->fields obj)
    (cases object obj
        (an-object (class-name fields) fields)
    )
)

(define (new-object class-name)
    (an-object
       class-name
       (map
        (lambda (field-name) (newref (list 'uninitialized field-name)))
        (class->field-names (lookup-class class-name))
       )
    )
)
