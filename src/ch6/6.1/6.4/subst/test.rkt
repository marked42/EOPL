#lang eopl

(require rackunit)

(provide (all-defined-out))

(define (test-subst subst)
  (check-equal? (subst 'a 'b 'b) 'a "subst symbol")
  (check-equal? (subst 'a 'b 'c) 'c "subst symbol")
  (check-equal? (subst 'a 'b '()) '() "subst symbol in empty list")
  (check-equal? (subst 'a 'b '(b)) '(a) "subst symbol in list")
  (check-equal? (subst 'a 'b '(c)) '(c) "subst symbol in list")
  (check-equal? (subst 'a 'b '(a b c)) '(a a c) "subst symbol in list with multiple elements")
  (check-equal? (subst 'a 'b '((b c) (b () d))) '((a c) (a () d)) "subst symbol in nested list")
  )
