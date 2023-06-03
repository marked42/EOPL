#lang racket

(require rackunit)

; unary representation
; (define (zero) '())
; (define (is-zero? n) (null? n))
; (define (successor n) (cons #t n))
; (define (predecessor n) (cdr n))

; number representation
; (define (zero) 0)
; (define (is-zero? n) (zero? 0))
; (define (successor n) (+ n 1))
; (define (predecessor n) (- n 1))

; bignum representation
; 0 -> ()
; (r . q)

; exer 2.1

(define N 16)
(define (zero) '())
(define (is-zero? n) (null? n))
(define (successor n)
  (if (is-zero? n)
      (list 1)
      (let ((first (car n)) (rest (cdr n)))
        (if (= (- N 1) first)
            (cons 0 (successor rest))
            (cons (+ first 1) rest)
            )
        )
      )
  )

(define (predecessor n)
  (if (is-zero? n)
      (error "out of range, predecessor of 0 is -1, cannot be represented")
      (let ((first (car n)) (rest (cdr n)))
        (if (= first 0)
            (cons (- N 1) (predecessor rest))
            (begin
              (display (list N rest))
              (cons (- first 1) rest)
              )
            )
        )
      )
  )

; exer 2.2
; (predecessor 0) 发生underflow，无法表示

(check-equal? (is-zero? (zero)) #t "should return true")
(check-equal? (successor (zero)) (list 1) "successor")
(check-equal? (successor (list 15)) (list 0 1) "successor with carry")

(check-equal? (predecessor '(1)) (zero) "predecessor of 1 is 0")
