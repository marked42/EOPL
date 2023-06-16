#lang eopl

(require racket/list racket/vector)

(provide (all-defined-out))

(define (empty-store) (make-vector 0 0))

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
  (let ([next-ref (vector-length the-store)])
    (set! the-store (vector-append the-store (vector val)))
    next-ref
    )
  )

(define (deref ref)
  (vector-ref the-store ref)
  )

(define (setref! ref val)
  (vector-set! the-store ref val)
  )

(define (report-invalid-reference ref the-store)
  (eopl:error 'setref! "illegal reference ~s in store ~s" ref the-store)
  )
