#lang eopl

(require racket/lazy-require "procedure.rkt")
(lazy-require
 ["environment.rkt" (extend-env*)]
 ["store.rkt" (newref)]
 ["value.rkt" (proc-val)]
 )

(provide (all-defined-out))

; an object is ListOf(Symbol * Proc)
(define (newobject method-names procs)
  (map (lambda (name proc) (list name proc)) method-names procs)
  )

(define (get-object-method obj method-name)
  (let ([maybe-pair (assq method-name obj)])
    (if (pair? maybe-pair)
        (cases proc (cadr maybe-pair)
          (procedure (vars body saved-env)
                     ; inject %self
                     (proc-val
                      (procedure vars body (extend-env* (list '%self) (list (newref obj)) saved-env)))
                     )
          )
        (report-method-not-found obj method-name)
        )
    )
  )

(define (report-method-not-found obj method-name)
  (eopl:error 'get-object-method "Method ~s not found on object ~s" method-name obj)
  )
