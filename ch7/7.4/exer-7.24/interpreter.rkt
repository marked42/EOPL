#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env*
                     extend-env-rec*
                     )]
 ["value.rkt" (num-val expval->num bool-val expval->bool proc-val expval->proc)]
 ["procedure.rkt" (procedure apply-procedure)]
 ["inferrer/main.rkt" (type-of-program)]
 ["typed-var.rkt" (typed-var->var)]
 )

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  (type-of-program prog)
  (cases program prog
    (a-program (exp1) (value-of-exp exp1 (init-env)))
    )
  )

(define (value-of-exp exp env)
  (cases expression exp
    (const-exp (num) (num-val num))
    (var-exp (var) (apply-env env var))
    (diff-exp (exp1 exp2)
              (let ([val1 (value-of-exp exp1 env)]
                    [val2 (value-of-exp exp2 env)])
                (let ((num1 (expval->num val1))
                      (num2 (expval->num val2)))
                  (num-val (- num1 num2))
                  )
                )
              )
    (zero?-exp (exp1)
               (let ([val (value-of-exp exp1 env)])
                 (let ([num (expval->num val)])
                   (if (zero? num)
                       (bool-val #t)
                       (bool-val #f)
                       )
                   )
                 )
               )
    (if-exp (exp1 exp2 exp3)
            (let ([val1 (value-of-exp exp1 env)])
              (if (expval->bool val1)
                  (value-of-exp exp2 env)
                  (value-of-exp exp3 env)
                  )
              )
            )
    (let-exp (vars exps body)
             (let ([vals (value-of-exps exps env)])
               (value-of-exp body (extend-env* vars vals env))
               )
             )
    (proc-exp (typed-vars body)
              (proc-val (procedure (map typed-var->var typed-vars) body env))
              )
    (call-exp (rator rands)
              (let ([rator-val (value-of-exp rator env)] [rand-vals (value-of-exps rands env)])
                (let ([proc1 (expval->proc rator-val)])
                  (apply-procedure proc1 rand-vals)
                  )
                )
              )
    (letrec-exp (p-result-type p-name b-typed-var p-body body)
                (let ([new-env (extend-env-rec* (list p-name) (list (typed-var->var b-typed-var)) (list p-body) env)])
                  (value-of-exp body new-env)
                  )
                )
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )

(define (value-of-exps exps env)
  (map (lambda (exp) (value-of-exp exp env)) exps)
)
