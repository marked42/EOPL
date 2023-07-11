#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt" "module.rkt")
(lazy-require
 ["environment.rkt" (
                     empty-env
                     apply-env
                     extend-env*
                     extend-env-rec*
                     extend-env-with-module
                     lookup-qualified-var-in-env
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
    (letrec-module-body (p-result-types p-names b-vars b-var-types p-bodies definitions)
                        (let ([new-env (extend-env-rec* p-names b-vars p-bodies env)])
                          (simple-module (definitions-to-env definitions new-env))
                          )
                        )
    (let-module-body (vars exps definitions)
                     (let ([new-env (extend-env* vars (value-of-exps exps env) env)])
                      (simple-module (definitions-to-env definitions new-env))
                      )
                     )
    )
  )

(define (definitions-to-env defs env)
  (if (null? defs)
      env
      (cases definition (car defs)
        (val-definition (var-name exp)
                        (definitions-to-env
                          (cdr defs)
                          ; let* scoping rule
                          (extend-env* (list var-name) (list (value-of-exp exp env)) env)
                          )
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
    (let-exp (vars exps body)
             (let ([vals (value-of-exps exps env)])
               (value-of-exp body (extend-env* vars vals env))
               )
             )
    (proc-exp (params body)
              (proc-val (procedure (map parameter->var params) body env))
              )
    (call-exp (rator rands)
              (let ([rator-val (value-of-exp rator env)] [rand-vals (value-of-exps rands env)])
                (let ([proc1 (expval->proc rator-val)])
                  (apply-procedure proc1 rand-vals)
                  )
                )
              )
    (letrec-exp (p-result-types p-names b-vars b-var-types p-bodies body)
                (let ([new-env (extend-env-rec* p-names b-vars p-bodies env)])
                  (value-of-exp body new-env)
                  )
                )
    (qualified-var-exp (m-name var-name)
                       (lookup-qualified-var-in-env m-name var-name env)
                       )
    (true-exp () (bool-val #t))
    (false-exp () (bool-val #f))
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )

(define (value-of-exps exps env)
  (map (lambda (exp) (value-of-exp exp env)) exps)
  )
