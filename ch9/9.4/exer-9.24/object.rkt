#lang eopl

(require racket/lazy-require racket/list "parser.rkt" "expression.rkt")

(lazy-require
 ["store.rkt" (reference? newref)]
 ["class.rkt" (class->field-names lookup-class find-super-class-name)]
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

(define (find-object-field class-name obj field-name)
  (let loop ([current-class-name (object->class-name obj)])
    (cond
      [(not current-class-name) (eopl:error 'find-object-field "Object ~s is not instance of class ~s, cannot access named-class field ~s." obj current-class-name field-name)]
      [(eqv? current-class-name class-name)
       (let* ([obj-class (lookup-class class-name)]
              [field-names (class->field-names obj-class)]
              [index (index-of field-names field-name)])
         (if index
             (list-ref (object->fields obj) index)
             (eopl:error 'find-object-field "Class ~s has no field ~s." class-name field-name)
             )
         )
       ]
      [else (loop (find-super-class-name current-class-name))]
      )
    )
  )
