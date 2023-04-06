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
        (translation-of-exp body (extend-senv var env))
      )
    )

    (proc-exp (name body)
      (nameless-proc-exp
        (translation-of-exp body (extend-senv name env))
      )
    )
    (call-exp (rator rand)
      (call-exp
        (translation-of-exp rator env)
        (translation-of-exp rand env)
      )
    )
    (else 43)
    )
  )
