#lang eopl

(require racket/lazy-require "expression.rkt")
(lazy-require
 ["static-environment.rkt" (
                            init-senv
                            apply-senv
                            extend-senv
                            )]
 )

(provide (all-defined-out))

(define (translation-of-program prog)
  (cases program prog
    (a-program (exp1)
               (a-program (translation-of-exp exp1 (init-senv)))
               )
    )
  )

(define (translation-of-exp exp senv)
  (cases expression exp
    (const-exp (num) exp)
    (diff-exp (exp1 exp2)
              (diff-exp
               (translation-of-exp exp1 senv)
               (translation-of-exp exp2 senv)
               )
              )
    (zero?-exp (exp1)
               (zero?-exp (translation-of-exp exp1 senv))
               )
    (if-exp (exp1 exp2 exp3)
            (if-exp
             (translation-of-exp exp1 senv)
             (translation-of-exp exp2 senv)
             (translation-of-exp exp3 senv)
             )
            )
    (var-exp (var) (let* ([pair (apply-senv senv var)] [depth (car pair)] [position (cdr pair)])
                     (nameless-var-exp depth position)
                     )
             )
    (let-exp (vars exps body)
             (nameless-let-exp
              (translation-of-exps exps senv)
              (translation-of-exp body (extend-senv vars senv))
              )
             )
    (proc-exp (vars body)
              (nameless-proc-exp
               (translation-of-exp body (extend-senv vars senv))
               )
              )
    (call-exp (rator rands)
              (call-exp
               (translation-of-exp rator senv)
               (translation-of-exps rands senv)
               )
              )
    (else (eopl:error 'translation-of-exp "unsupported expression type ~s" exp))
    )
  )

(define (translation-of-exps exps senv)
  (map (lambda (exp) (translation-of-exp exp senv)) exps)
  )
