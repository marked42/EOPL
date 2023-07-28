#lang eopl

(require racket/list racket/lazy-require "parser.rkt" "expression.rkt")

(lazy-require
 ["store.rkt" (reference? newref)]
 ["class.rkt" (class->field-names lookup-class class->super-name)]
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

(define (object->field obj field-name)
  (let* ([host-class (lookup-class (object->class-name obj))]
         [field-names (class->field-names host-class)]
         [index (index-of field-names field-name)])
    (if index
        (list-ref (object->fields obj) index)
        (eopl:error 'object->field "Field ~s not found on object ~s" field-name obj)
        )
    )
  )

(define (object->super-field obj super-field-name)
  (let* ([host-class (lookup-class (object->class-name obj))]
         [super-name (class->super-name host-class)]
         [super-class (lookup-class super-name)]
         [super-field-names (class->field-names super-class)]
         [index (index-of super-field-names super-field-name)])
    (if index
        (list-ref (object->fields obj) index)
        (eopl:error 'object->super-field "Super field ~s not found on object ~s" super-field-name obj)
        )
    )
  )
