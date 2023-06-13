#lang eopl

(require racket rackunit)

(provide (all-defined-out))

(define (test-environment empty-env extend-env apply-env)
  (let ([env (extend-env 'i 1 (extend-env 'v 5 (extend-env 'x 10 (empty-env))))])
    (check-equal? (apply-env env 'i) 1 "value of variable i is 1")
    (check-equal? (apply-env env 'v) 5 "value of variable v is 5")
    (check-equal? (apply-env env 'x) 10 "value of variable x is 10")

    (check-exn exn:fail? (lambda () (apply-env 'non-exist-var)))
    )
  )

(define (test-environment* empty-env extend-env* apply-env)
  (let ([env (extend-env* '(i v x) '(1 5 10) (empty-env))])
    (check-equal? (apply-env env 'i) 1 "value of variable i is 1")
    (check-equal? (apply-env env 'v) 5 "value of variable v is 5")
    (check-equal? (apply-env env 'x) 10 "value of variable x is 10")

    (check-exn exn:fail? (lambda () (apply-env 'non-exist-var)))
    )
  )

(define (test-empty-env? empty-env empty-env? extend-env)
  (check-equal? (empty-env? (empty-env)) #t "empty-env?")
  (check-equal? (empty-env? (extend-env 'i 1 (empty-env))) #f "empty-env?")
  )

(define (test-has-binding? empty-env extend-env has-binding?)
  (let ([env (extend-env 'i 1 (extend-env 'v 5 (extend-env 'x 10 (empty-env))))])
    (check-equal? (has-binding? env 'i) #t "has-binding? i should be true")
    (check-equal? (has-binding? env 'v) #t "has-binding? v should be true")
    (check-equal? (has-binding? env 'x) #t "has-binding? x should be true")
    (check-equal? (has-binding? env 'non-exist-var) #f "has-binding non-exist-var should be false")
    )
  )
