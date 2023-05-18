#lang eopl

(require racket/list "test.rkt" "shared.rkt")

(define (occurs-free? var exp)
  (occurs-free/k? var exp (end-cont))
  )

(define (occurs-free/k? var exp cont)
  (cond
    ((symbol? exp) (apply-cont cont (eqv? var exp)))
    ((eqv? (first exp) 'lambda)
     (if (not (eqv? var (get-lambda-var exp)))
         (occurs-free/k? var (get-lambda-body exp) cont)
         (apply-cont cont #f)
         )
     )
    (else
     (occurs-free/k? var (get-call-operator exp)
                     (operand-cont cont var (get-call-operand exp))
                     )
     )
    )
  )

(define (end-cont)
  (lambda (val)
    (eopl:printf "End of computation.~%")
    (eopl:printf "This sentence should appear only once.~%")
    val
    )
  )

(define (operand-cont saved-cont var operand-exp)
  (lambda (val)
    (if val
        (apply-cont saved-cont #t)
        (occurs-free/k? var operand-exp saved-cont)
        )
    )
  )
(define (apply-cont cont val)
  (cont val)
  )

(test-occurs-free? occurs-free?)
