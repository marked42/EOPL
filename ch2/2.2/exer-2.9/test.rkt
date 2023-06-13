#lang eopl

(require rackunit "environment.rkt" "../../test.rkt")

(test-environment empty-env extend-env apply-env)

(define (test-has-binding?)
  (let ([env (extend-env 'i 1 (extend-env 'v 5 (extend-env 'x 10 (empty-env))))])
    (check-equal? (has-binding? env 'i) #t "has-binding? i should be true")
    (check-equal? (has-binding? env 'v) #t "has-binding? v should be true")
    (check-equal? (has-binding? env 'x) #t "has-binding? x should be true")
    (check-equal? (has-binding? env 'non-exist-var) #f "has-binding non-exist-var should be false")
    )
  )

(test-has-binding?)
