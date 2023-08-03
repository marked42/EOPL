#lang eopl

(require racket/lazy-require "procedure.rkt")
(lazy-require
 ["environment.rkt" (extend-env*)]
 ["store.rkt" (newref)]
 ["value.rkt" (proc-val)]
 ["maybe.rkt" (maybe)]
 )

(provide (all-defined-out))

(define-datatype prototype-decl prototype-decl?
  (empty-prototype)
  (single-prototype (name symbol?))
  )

(define (prototype-decl->name p-decl)
  (cases prototype-decl p-decl
    (empty-prototype () #f)
    (single-prototype (name) name)
    )
  )

(define-datatype object object?
  (an-object (methods object-methods?) (prototype (maybe object?)))
  )

(define object-methods? (list-of (lambda (p) (and
                                              (pair? p)
                                              (symbol? (car p))
                                              (proc? (cadr p))
                                              ))))

; an object is ListOf(Symbol * Proc)
(define (newobject method-names procs prototype)
  (an-object
   (map (lambda (name proc) (list name proc)) method-names procs)
   prototype
   )
  )

(define (get-object-method obj method-name)
  (if obj
      (cases object obj
        (an-object (methods prototype)
                   (let ([maybe-pair (assq method-name methods)])
                     (if (pair? maybe-pair)
                         (cases proc (cadr maybe-pair)
                           (procedure (vars body saved-env)
                                      ; inject %self
                                      (proc-val
                                       (procedure vars body (extend-env* (list '%self) (list (newref obj)) saved-env)))
                                      )
                           )
                         (get-object-method prototype method-name)
                         )
                     )
                   )
        )
      (report-method-not-found obj method-name)
      )
  )

(define (report-method-not-found obj method-name)
  (eopl:error 'get-object-method "Method ~s not found on object ~s" method-name obj)
  )
