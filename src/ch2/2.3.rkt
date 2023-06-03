#lang eopl

(require rackunit "ch1.rkt")

(define zero '(diff (one) (one)))

(define (eval n)
  (if (eqv? (car n) 'one)
      1
      (let ((left (cadr n)) (right (caddr n)))
        (- (eval left) (eval right))
        )
      )
  )

(check-equal? (eval zero) 0 "0")
(check-equal? (eval '(one)) 1 "1")

(define (is-zero? n)
  (eqv? (eval n) 0)
  )
(check-equal? (is-zero? zero) #t "is-zero?")

(define (successor tree)
  (define minus-one (list 'diff zero '(one)))
  (list 'diff tree minus-one)
  )

(check-equal? (eval (successor zero)) 1 "successor of 0 is 1")
(check-equal? (eval (successor '(one))) 2 "successor of 1 is 2")

(define (predecessor n)
  (list 'diff n '(one))
  )

(check-equal? (eval (predecessor zero)) -1 "predecessor of 0 is -1")
(check-equal? (eval (predecessor '(one))) 0 "predecessor of 1 is 0")

(define (diff-tree-plus a b)
  (list 'diff a (list 'diff zero b))
  )

(check-equal? (eval (diff-tree-plus '(one) '(one))) 2 "1 + 1 = 2")
