#lang eopl

(require rackunit)

(provide (all-defined-out))

(define (test-occurs-free? occurs-free?)
  (check-equal? (occurs-free? 'x 'x) #t "free identifier")
  (check-equal? (occurs-free? 'x 'y) #f "non-free identifier")

  (check-equal? (occurs-free? 'x '(lambda (x) y)) #f "non-free identifier in lambda")
  (check-equal? (occurs-free? 'y '(lambda (x) y)) #t "free identifier in lambda")
  (check-equal? (occurs-free? 'z '(lambda (x) y)) #f "non-free identifier in lambda")

  (check-equal? (occurs-free? 'x '(x y)) #t "free identifier in lambda")
  (check-equal? (occurs-free? 'y '(x y)) #t "free identifier in lambda")
  (check-equal? (occurs-free? 'z '(x y)) #f "non-free identifier in lambda")
  )
