#lang eopl

(require racket/lazy-require)
(lazy-require
 ["store.rkt" (reference? newref deref setref )]
 )

(provide (all-defined-out))

(define-datatype array array?
  (an-array (start reference?) (length integer?))
  )

(define (newarray length value)
  (letrec ((start (newref value)) (loop (lambda (count)
                                          (if (zero? count)
                                              '()
                                              (begin
                                                (newref value)
                                                (loop (- count 1))
                                                )
                                              )
                                          )))
    (loop (- length 1))
    (an-array start length)
    )
  )

(define (arraylength arr)
  (cases array arr
    (an-array (start length) length)
    )
  )

(define (array-index-ref arr i)
  (cases array arr
    (an-array (start length) (+ start i))
    )
  )

(define (arrayref arr i)
  (if (or (< i 0) (>= i (arraylength arr)))
      (eopl:error "invalid index ~s " i)
      (deref (array-index-ref arr i))
      )
  )

(define (arrayset arr i val)
  (if (or (< i 0) (>= i (arraylength arr)))
      (eopl:error "invalid index ~s " i)
      (setref (array-index-ref arr i) val)
      )
  )
