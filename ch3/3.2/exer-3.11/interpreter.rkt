#lang eopl

(require racket/lazy-require racket/list "parser.rkt" "expression.rkt" "operator.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env
                     )]
 ["value.rkt" (num-val expval->num bool-val expval->bool)]
 )

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  (cases program prog
    (a-program (exp1) (value-of-exp exp1 (init-env)))
    )
  )

(define (value-of-exp exp env)
  (cases expression exp
    (const-exp (num) (num-val num))
    (var-exp (var) (apply-env env var))
    (if-exp (exp1 exp2 exp3)
            (let ([val1 (value-of-exp exp1 env)])
              (if (expval->bool val1)
                  (value-of-exp exp2 env)
                  (value-of-exp exp3 env)
                  )
              )
            )
    (let-exp (var exp1 body)
             (let ([val (value-of-exp exp1 env)])
               (value-of-exp body (extend-env var val env))
               )
             )
    (numeric-exp (op exps)
              (let ([vals (value-of-exps exps env)])
                (let ([nums (map expval->num vals)])
                  (value-of-numeric-exp op nums)
                  )
                )
              )
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )

(define (value-of-numeric-exp op nums)
  (cases operator op
    [binary-diff () (num-val (- (first nums) (second nums)))]
    [unary-zero? () (bool-val (= 0 (first nums)))]
    [unary-minus () (num-val (- 0 (first nums)))]
    [else (eopl:error "Unsupported numeric operator ~s" op)]
  )
)

(define (value-of-exps exps env)
  (map (lambda (exp) (value-of-exp exp env)) exps)
)
