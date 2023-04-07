#lang eopl

(require "expression.rkt")
(require "static-env.rkt")
(require racket/pretty)
(provide (all-defined-out))

(define (translation-of-program prog)
  (cases program prog
    (a-program (exp1)
               (a-program
                (translation-of-exp exp1 (init-senv)))
               )
    )
  )

(define (translation-of-exp exp env)
  (cases expression exp
    (const-exp (num) exp)
    (diff-exp (exp1 exp2)
              (diff-exp
               (translation-of-exp exp1 env)
               (translation-of-exp exp2 env)
               )
              )
    (zero?-exp (exp1)
               (zero?-exp (translation-of-exp exp1 env))
               )
    (if-exp (exp1 exp2 exp3)
            (if-exp
             (translation-of-exp exp1 env)
             (translation-of-exp exp2 env)
             (translation-of-exp exp3 env)
             )
            )
    (var-exp (var)
             (nameless-var-exp (apply-senv env var)))
    (let-exp (var exp body)
             (nameless-let-exp
              (translation-of-exp exp env)
              (translation-of-exp body (extend-senv (list var) env))
              )
             )
    (letrec-exp (p-name b-var p-body body)
                (let ((new-env (extend-senv (list p-name) env)))
                  (nameless-letrec-exp
                   (translation-of-exp p-body (extend-senv (list b-var) new-env))
                   (translation-of-exp body new-env)
                   )
                  )
                )

    (proc-exp (name body)
              (nameless-proc-exp
               (translation-of-exp body (extend-senv (list name) env))
               )
              )
    (call-exp (rator rand)
              (call-exp
               (translation-of-exp rator env)
               (translation-of-exp rand env)
               )
              )

    (cond-exp (cond-exps act-exps)
              (cond-exp
               (map (lambda (exp) (translation-of-exp exp env)) cond-exps)
               (map (lambda (exp) (translation-of-exp exp env)) act-exps)
               )
              )
    (else 43)
    )
  )
