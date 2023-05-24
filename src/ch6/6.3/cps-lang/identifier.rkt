#lang eopl

(provide (all-defined-out))

(define identifier-index 'uninitialized)

(define (initialize-identifier-index!)
  (set! identifier-index 0)
  )

(define (fresh-identifier identifier)
  (set! identifier-index (+ identifier-index 1))
  (string->symbol
   (string-append
    (symbol->string identifier)
    ; this can't appear in an input identifier
    "%"
    (number->string identifier-index))))
