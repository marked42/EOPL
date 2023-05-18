#lang eopl

(require racket/list "test.rkt" "shared.rkt")

(define (occurs-free? var exp)
  (cond
    ((symbol? exp) (eqv? var exp))
    ((eqv? (first exp) 'lambda)
     (and
      (not (eqv? var (get-lambda-var exp) ))
      (occurs-free? var (get-lambda-body exp))
      )
     )
    (else
     (or
      (occurs-free? var (get-call-operator exp))
      (occurs-free? var (get-call-operand exp))
      )
     )
    )
  )

(test-occurs-free? occurs-free?)
