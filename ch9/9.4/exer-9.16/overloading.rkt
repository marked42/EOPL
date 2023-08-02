#lang eopl

(provide (all-defined-out))

(define (mangle-method-name method-name arity)
  (string->symbol
   (string-append
    (symbol->string method-name)
    ; method name from user cannot contain %
    "%"
    (number->string arity)
    )
   )
  )
