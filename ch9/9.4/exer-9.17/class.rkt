#lang eopl

(require racket/lazy-require racket/list "expression.rkt")

(lazy-require
 ["method.rkt" (a-method method?)]
 ["environment.rkt" (extend-env-with-class-decl lookup-class)]
 )

(provide (all-defined-out))

(define method-environment? (list-of (lambda (p) (and
                                                  (pair? p)
                                                  (symbol? (car p))
                                                  (method? (cadr p))
                                                  ))))
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

(define (report-unknown-class-name name)
  (eopl:error 'lookup-class "Unknown class name ~s" name)
  )

(define (initialize-class-env c-decls env)
  (if (null? c-decls)
      env
      (initialize-class-env
       (cdr c-decls)
       (extend-env-with-class-decl (car c-decls) env)
       )
      )
  )

; static dispatch
(define (merge-method-envs super-m-env new-m-env)
  (append new-m-env super-m-env)
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

(define (find-method c-name m-name env)
  ; static dispatch by assq
  (let* ([m-env (class->method-env (lookup-class c-name env))] [maybe-pair (assq m-name m-env)])
    (if (pair? maybe-pair)
        (cadr maybe-pair)
        (report-method-not-found m-name c-name)
        )
    )
  )

(define (report-method-not-found m-name c-name)
  (eopl:error 'find-method "Method ~s not found on class ~s" m-name c-name)
  )

(define (append-filed-names super-fields new-fields)
  (if (null? super-fields)
      new-fields
      (let ([first-super-field (car super-fields)] [rest-super-fields (cdr super-fields)])
        (cons
         (if (memq first-super-field new-fields)
             (fresh-identifier first-super-field)
             first-super-field
             )
         (append-filed-names rest-super-fields new-fields)
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

(define (create-a-class c-name s-name f-names m-decls env)
  (let* ([super-class (lookup-class s-name env)]
         [super-class-f-names (class->field-names super-class)]
         [f-names (append-filed-names super-class-f-names f-names)])
    (a-class s-name f-names
             (merge-method-envs
              (class->method-env super-class)
              (method-decls->method-env m-decls s-name f-names)
              )
             )
    )
  )
