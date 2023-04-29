#lang eopl

(require rackunit)

; (define (fact-iter n)
;   (fact-iter-acc n 1)
;   )

; (define (fact-iter-acc n a)
;   (if (zero? n) a (fact-iter-acc (- n 1) (* n a)))
;   )

(define n 'uninitialized)
(define a 'uninitialized)

(define (fact m)
  (set! n m)
  (set! a 1)
  (fact-iter)
  )

(define (fact-iter)
  (if (zero? n)
      a
      (begin
        (set! a (* n a))
        (set! n (- n 1))
        (fact-iter)
        )
      )
  )

(check-equal? (fact 0) 1)
(check-equal? (fact 1) 1)
(check-equal? (fact 2) 2)
(check-equal? (fact 3) 6)
