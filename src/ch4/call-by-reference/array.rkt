#lang eopl

(require racket/lazy-require)
(lazy-require
 ["store.rkt" (newref deref setref show-store)]
 )

(provide (all-defined-out))

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
    start
    )
  )

(define (arrayref arr i)
  (+ arr i)
  )

(define (arrayset arr i val)
  (setref (+ arr i) val)
  )
