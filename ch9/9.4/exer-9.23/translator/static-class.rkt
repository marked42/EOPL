#lang eopl

(require racket/list "../expression.rkt")

(provide (all-defined-out))

(define (find-method-index c-name method-name)
  (let ([class-method-names (lookup-class c-name)])
    (index-of class-method-names method-name)
    )
  )

; the-static-class-env = ListOf(ClassName * MethodNames)
; ClassName = Symbol
; MemberNames = ListOf(Symbol)
(define the-static-class-env '())

(define (initialize-class-env! c-decls)
  (set! the-static-class-env (list (list 'object '())))
  (for-each initialize-class-decl! c-decls)
  )

(define (initialize-class-decl! c-decl)
  (cases class-decl c-decl
    (a-class-decl (c-name s-name f-names m-decls)
                  (add-to-class-env!
                   c-name
                   (append
                    (map method-decl->method-name m-decls)
                    (lookup-class s-name)
                    )
                   )
                  )
    )
  )


(define (add-to-class-env! class-name class-methods)
  (set! the-static-class-env
        (cons (list class-name class-methods) the-static-class-env)
        )
  )

(define (lookup-class name)
  (let ([maybe-pair (assq name the-static-class-env)])
    (if maybe-pair
        (second maybe-pair)
        (report-unknown-class-name name)
        )
    )
  )

(define (report-unknown-class-name name)
  (eopl:error 'lookup-class "Unknown class name ~s" name)
  )

(define (method-decl->method-name m-decl)
  (cases method-decl m-decl
    (a-method-decl (method-name vars body) method-name)
    )
  )
