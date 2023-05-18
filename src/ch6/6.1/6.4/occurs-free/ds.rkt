#lang eopl

(require racket/list "test.rkt" "shared.rkt")

; LcExp ::= Identifier
;       ::= (lambda (Identifier) LcExp)
;       ::=(LcExp LcExp)

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

(define-datatype continuation cont?
  (end-cont)
  (operand-cont (saved-cont cont?) (var symbol?) (exp (or symbol? list?)))
  )

(define (apply-cont cont val)
  (cases continuation cont
    (end-cont ()
              (eopl:printf "End of computation.~%")
              (eopl:printf "This sentence should appear only once.~%")
              val
              )
    (operand-cont (saved-cont var operand-exp)
                  (if val
                      (apply-cont saved-cont #t)
                      (occurs-free/k? var operand-exp saved-cont)
                      )
                  )
    )
  )

(test-occurs-free? occurs-free?)
