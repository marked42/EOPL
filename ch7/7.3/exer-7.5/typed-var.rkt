#lang eopl

(require "checker/type.rkt")

(provide (all-defined-out))

(define-datatype typed-var typed-var?
  (a-typed-var (var symbol?) (type type?))
  )

(define (typed-var->var t-var)
  (cases typed-var t-var
    (a-typed-var (var type) var)
    )
  )

(define (typed-var->type t-var)
  (cases typed-var t-var
    (a-typed-var (var type) type)
    )
  )

(define (typed-vars->vars t-vars)
  (map typed-var->var t-vars)
  )

(define (typed-vars->types t-vars)
  (map typed-var->type t-vars)
  )
