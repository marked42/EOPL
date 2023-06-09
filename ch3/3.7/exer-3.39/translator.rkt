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
    (var-exp (var) (nameless-var-exp (apply-senv senv var)))
    (let-exp (var exp1 body)
             (nameless-let-exp
              (translation-of-exp exp1 senv)
              (translation-of-exp body (extend-senv var senv))
              )
             )
    (proc-exp (var body)
              (nameless-proc-exp
               (translation-of-exp body (extend-senv var senv))
               )
              )
    (call-exp (rator rand)
              (call-exp
               (translation-of-exp rator senv)
               (translation-of-exp rand senv)
               )
              )

    ; new suff
    (cons-exp (exp1 exp2)
              (cons-exp (translation-of-exp exp1 senv) (translation-of-exp exp2 senv))
              )
    (car-exp (exp1)
             (car-exp (translation-of-exp exp1 senv))
             )
    (cdr-exp (exp1)
             (cdr-exp (translation-of-exp exp1 senv))
             )
    (emptylist-exp () exp)
    (null?-exp (exp1)
               (null?-exp (translation-of-exp exp1 senv))
               )
    ; new stuff
    (unpack-exp (vars exp1 body)
                (nameless-unpack-exp
                 (translation-of-exp exp1 senv)
                 (translation-of-exp body (extend-senv-unpack vars senv))
                 )
                )
    (else (eopl:error 'translation-of-exp "unsupported expression type ~s" exp))
    )
  )

; new stuff
(define (extend-senv-unpack vars senv)
  (if (null? vars)
      senv
      (extend-senv-unpack (cdr vars) (extend-senv (car vars) senv))
      )
  )
