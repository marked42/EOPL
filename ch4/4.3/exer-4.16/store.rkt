#lang eopl

(require racket/list)

(provide (all-defined-out))

(define (empty-store) '())

(define the-store 'uninitialized)

(define (get-store) the-store)

(define (initialize-store!)
  (set! the-store (empty-store))
  )

(define (show-store)
  (eopl:pretty-print (list "store is: " the-store))
  )

(define (reference? v) (integer? v))

(define (newref val)
  (let ([next-ref (length the-store)])
    (set! the-store (append the-store (list val)))
    next-ref
    )
  )

(define (deref ref)
  (list-ref the-store ref)
  )

(define (setref! ref val)
  (set! the-store (list-set the-store ref val))
  )

(define (report-invalid-reference ref the-store)
  (eopl:error 'setref! "illegal reference ~s in store ~s" ref the-store)
  )
