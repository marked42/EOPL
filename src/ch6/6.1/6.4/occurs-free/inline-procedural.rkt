#lang eopl

(require racket/list "test.rkt" "shared.rkt")

(define (occurs-free? var exp)
  (occurs-free/k? var exp
                  (lambda (val)
                    (eopl:printf "End of computation.~%")
                    (eopl:printf "This sentence should appear only once.~%")
                    val
                    )
                  )
  )

(define (occurs-free/k? var exp cont)
  (cond
    ((symbol? exp) (cont (eqv? var exp)))
    ((eqv? (first exp) 'lambda)
     (if (not (eqv? var (get-lambda-var exp)))
         (occurs-free/k? var (get-lambda-body exp) cont)
         (cont #f)
         )
     )
    (else
     (occurs-free/k? var (get-call-operator exp)
                     (lambda (val)
                       (if val
                           (cont #t)
                           (occurs-free/k? var (get-call-operand exp) cont)
                           )
                       )
                     )
     )
    )
  )


(test-occurs-free? occurs-free?)
