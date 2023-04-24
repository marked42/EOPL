#lang eopl

(provide (all-defined-out))

(define (try-conts) 'uninitialized)
(define (initialize-try-conts!) (set! try-conts '()))
(define (get-top-try-cont) (car try-conts))
(define (push-try-cont try-cont) (set! try-conts (cons try-cont try-conts)))
(define (pop-try-cont)
  (if (null? try-conts)
      (eopl:error 'try-conts-underflow try-conts)
      (let ((first (car try-conts)) (rest (cdr try-conts)))
        (set! try-conts rest)
        first
        )
      )
  )
