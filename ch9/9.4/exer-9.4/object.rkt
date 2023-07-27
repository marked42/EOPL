#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")

(lazy-require
 ["store.rkt" (reference? newref)]
 ["class.rkt" (class->field-names lookup-class class?)]
 )

(provide (all-defined-out))

(define-datatype object object?
    (an-object (a-class class?) (fields (list-of reference?)))
)

(define (object->class obj)
    (cases object obj
        (an-object (a-class fields) a-class)
    )
)

(define (object->fields obj)
    (cases object obj
        (an-object (a-class fields) fields)
    )
)

(define (new-object class-name)
    (an-object
       (lookup-class class-name)
       (map
        (lambda (field-name) (newref (list 'uninitialized field-name)))
        (class->field-names (lookup-class class-name))
       )
    )
)
