#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env
                     extend-env-rec
                     )]
 ["value.rkt" (num-val expval->num bool-val expval->bool proc-val expval->proc ref-val expval->ref)]
 ["procedure.rkt" (procedure apply-procedure)]
 ["store.rkt" (initialize-store! newref deref setref!)]
 )

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  (initialize-store!)
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
    (let-exp (var exp1 body)
             (let ([val (value-of-exp exp1 env)])
               (value-of-exp body (extend-env var val env))
               )
             )
    (proc-exp (var body)
              (proc-val (procedure var body env))
              )
    (call-exp (rator rand)
              (let ((rator-val (value-of-exp rator env)) (rand-val (value-of-exp rand env)))
                (let ((proc1 (expval->proc rator-val)))
                  (apply-procedure proc1 rand-val)
                  )
                )
              )
    (letrec-exp (p-name b-var p-body body)
                (let ((new-env (extend-env-rec p-name b-var p-body env)))
                  (value-of-exp body new-env)
                  )
                )

    ; new stuff
    (newref-exp (exp1)
                (ref-val (newref (value-of-exp exp1 env)))
                )
    (deref-exp (exp1)
               (let ([ref (expval->ref (value-of-exp exp1 env))])
                 (deref ref)
                 )
               )
    (setref-exp (exp1 exp2)
                (let ([val1 (value-of-exp exp1 env)] [val2 (value-of-exp exp2 env)])
                  (let ([ref1 (expval->ref val1)])
                    (setref! ref1 val2)
                    ; return an arbitrary val since we don't care the return value of setref!
                    (num-val 23)
                    )
                  )
                )
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )
