#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt" "module.rkt")
(lazy-require
 ["environment.rkt" (
                     empty-env
                     apply-env
                     extend-env
                     extend-env-rec
                     extend-env-with-module
                     lookup-qualified-var-in-env
                     lookup-module-name-in-env
                     )]
 ["value.rkt" (num-val expval->num bool-val expval->bool proc-val expval->proc)]
 ["procedure.rkt" (procedure apply-procedure)]
 ["checker/main.rkt" (type-of-program)]
 ["module.rkt" (simple-module)]
 )

(provide (all-defined-out))

(define (run str)
  (let ([prog (scan&parse str)])
    (type-of-program prog)
    (value-of-program prog)
    )
  )

(define (value-of-program prog)
  (cases program prog
    (a-program (m-defs body)
               (let ([env (add-module-definitions-to-env m-defs (empty-env))])
                 (value-of-exp body env)
                 )
               )
    )
  )

(define (add-module-definitions-to-env defs env)
  (if (null? defs)
      env
      (cases module-definition (car defs)
        (a-module-definition (m-name expected-interface m-body)
                             (add-module-definitions-to-env
                              (cdr defs)
                              (extend-env-with-module
                               m-name
                               (value-of-module-body m-body env)
                               env
                               )
                              )
                             )
        )
      )
  )

(define (value-of-module-body m-body env)
  (cases module-body m-body
    (definitions-module-body (definitions)
      (simple-module (definitions-to-env definitions env))
      )
    (var-module-body (m-name)
                     (lookup-module-name-in-env m-name env)
                     )
    (proc-module-body (m-name m-type m-body)
                      (proc-module m-name m-body env)
                      )
    (app-module-body (rator rand)
                     (let ([rator-val (lookup-module-name-in-env rator env)]
                           [rand-val (lookup-module-name-in-env rand env)])
                       (cases typed-module rator-val
                         (proc-module (m-name m-body env)
                                      (value-of-module-body m-body (extend-env-with-module m-name rand-val env))
                                      )
                         (else (report-bad-module-app rator-val))
                         )
                       )
                     )
    )
  )

(define (report-bad-module-app val)
  (eopl:error 'value-of-module-body "Expect a proc module, get ~s" val)
  )

(define (definitions-to-env defs env)
  (if (null? defs)
      env
      (cases definition (car defs)
        (val-definition (var-name exp)
                        (definitions-to-env
                          (cdr defs)
                          ; let* scoping rule
                          (extend-env var-name (value-of-exp exp env) env)
                          )
                        )
        (type-definition (var-name ty)
                         (definitions-to-env (cdr defs) env)
                         )
        )
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
    (proc-exp (var var-type body)
              (proc-val (procedure var body env))
              )
    (call-exp (rator rand)
              (let ([rator-val (value-of-exp rator env)] [rand-val (value-of-exp rand env)])
                (let ([proc1 (expval->proc rator-val)])
                  (apply-procedure proc1 rand-val)
                  )
                )
              )
    (letrec-exp (p-result-type p-name b-var b-var-type p-body body)
                (let ([new-env (extend-env-rec p-name b-var p-body env)])
                  (value-of-exp body new-env)
                  )
                )
    (qualified-var-exp (m-name var-name)
                       (lookup-qualified-var-in-env m-name var-name env)
                       )
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )
