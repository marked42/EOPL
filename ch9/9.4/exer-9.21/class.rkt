#lang eopl

(require racket/base racket/lazy-require racket/list "expression.rkt")

(lazy-require
 ["method.rkt" (a-method method?)]
 )

(provide (all-defined-out))

(define method-environment? hash?)

(define-datatype class class?
  (a-class
   (super-name (maybe symbol?))
   (field-names (list-of symbol?))
   (method-env method-environment?)
   )
  )

(define (class->field-names c)
  (cases class c
    (a-class (super-name field-names method-env) field-names)
    )
  )

(define (class->super-name c)
  (cases class c
    (a-class (super-name field-names method-env) super-name)
    )
  )

(define (class->method-env c)
  (cases class c
    (a-class (super-name field-names method-env) method-env)
    )
  )

(define the-class-env '())

(define (add-to-class-env! class-name class)
  (set! the-class-env
        (cons (list class-name class) the-class-env)
        )
  )

(define (lookup-class name)
  (let ([maybe-pair (assq name the-class-env)])
    (if maybe-pair
        (second maybe-pair)
        (report-unknown-class-name name)
        )
    )
  )

(define (report-unknown-class-name name)
  (eopl:error 'lookup-class "Unknown class name ~s" name)
  )

(define (initialize-class-env! c-decls)
  (set! the-class-env (list (list 'object (a-class #f '() (hash)))))
  (for-each initialize-class-decl! c-decls)
  )

(define (initialize-class-decl! c-decl)
  (cases class-decl c-decl
    (a-class-decl (c-name s-name f-names m-decls)
                  (let* ([super-class-f-names (class->field-names (lookup-class s-name))]
                         [f-names (append-field-names super-class-f-names f-names)])
                    (add-to-class-env!
                     c-name
                     (a-class s-name f-names
                              (merge-method-envs
                               (class->method-env (lookup-class s-name))
                               (method-decls->method-env m-decls s-name f-names)
                               )
                              )
                     )
                    )
                  )
    )
  )

; static dispatch
(define (merge-method-envs super-m-env new-m-env)
  (let loop ([super-m-env super-m-env] [new-m-env new-m-env])
    (if (null? new-m-env)
        super-m-env
        (let* ([first-method (car new-m-env)]
               [first-method-name (car first-method)]
               [rest-methods (cdr new-m-env)])
          (loop
           (hash-set super-m-env first-method-name (cadr first-method))
           rest-methods)
          )
        )
    )
  )

(define (method-decls->method-env m-decls super-name field-names)
  (map (lambda (m-decl)
         (cases method-decl m-decl
           (a-method-decl (method-name vars body)
                          (list method-name (a-method vars body super-name field-names))
                          )
           )
         ) m-decls)
  )

(define (find-method c-name m-name)
  ; static dispatch
  (let* ([m-env (class->method-env (lookup-class c-name))])
    (if (hash-has-key? m-env m-name)
        (hash-ref m-env m-name)
        (report-method-not-found m-name c-name)
        )
    )
  )

(define (report-method-not-found m-name c-name)
  (eopl:error 'find-method "Method ~s not found on class ~s" m-name c-name)
  )

(define (append-field-names super-fields new-fields)
  (if (null? super-fields)
      new-fields
      (let ([first-super-field (car super-fields)] [rest-super-fields (cdr super-fields)])
        (cons
         (if (memq first-super-field new-fields)
             (fresh-identifier first-super-field)
             first-super-field
             )
         (append-field-names rest-super-fields new-fields)
         )
        )
      )
  )

(define sn 0)
(define (fresh-identifier field)
  (set! sn (+ sn 1))
  (string->symbol
   (string-append
    (symbol->string field)
    "%"             ; this can't appear in an input identifier
    (number->string sn)))
  )

(define (maybe pred)
  (lambda (v) (or (not v) (pred v)))
  )
