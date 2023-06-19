#lang eopl

(require racket/list "value.rkt")

(provide (all-defined-out))

(define store? (list-of expval?))

(define (empty-store) '())

(define (reference? v) (integer? v))

(define (newref the-store val)
  (cons
   (append the-store (list val))
   (length the-store)
   )
  )

(define (deref the-store ref)
  (cons
   the-store
   (list-ref the-store ref)
   )
  )

(define (setref! the-store ref val)
  ; return an arbitrary val since we don't care the return value of setref!
  (cons (list-set the-store ref val) (num-val 23))
  )

(define (report-invalid-reference ref the-store)
  (eopl:error 'setref! "illegal reference ~s in store ~s" ref the-store)
  )
