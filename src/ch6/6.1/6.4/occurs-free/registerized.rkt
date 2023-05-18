#lang eopl

(require racket/list "test.rkt" "shared.rkt")

(define var 'uninitialized)
(define exp 'uninitialized)
(define cont 'uninitialized)
(define answer 'unitialized)

(define (occurs-free? arg-var arg-exp)
  (set! var arg-var)
  (set! exp arg-exp)
  (set! cont (end-cont))
  (occurs-free/k?)
  )

(define (occurs-free/k?)
  (cond
    ((symbol? exp)
     (set! answer (eqv? var exp))
     (cont))

    ((eqv? (first exp) 'lambda)
     (if (not (eqv? var (get-lambda-var exp)))
         (begin
           (set! exp (get-lambda-body exp))
           (occurs-free/k?)
           )
         (begin
           (set! answer #f)
           (cont)
           )
         )
     )
    (else
     ; this line must be first, otherwise exp is written before get-call-operand read
     (set! cont (operand-cont cont (get-call-operand exp)))
     (set! exp (get-call-operator exp))
     (occurs-free/k?)
     )
    )
  )

(define (end-cont)
  (lambda ()
    (eopl:printf "End of computation.~%")
    (eopl:printf "This sentence should appear only once.~%")
    answer
    )
  )

(define (operand-cont saved-cont operand-exp)
  (lambda ()
    (if answer
        (begin
          (set! cont saved-cont)
          (cont)
          )
        (begin
          (set! exp operand-exp)
          (set! cont saved-cont)
          (occurs-free/k?)
          )
        )
    )
  )

(test-occurs-free? occurs-free?)
