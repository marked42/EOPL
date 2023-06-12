#lang eopl

(require racket/lazy-require "expression.rkt")
(lazy-require
 ["static-environment.rkt" (
                            init-senv
                            apply-senv
                            extend-senv-normal
                            extend-senv-letrec
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
    (var-exp (var)
             ; new stuf
             (let* ([index (apply-senv senv var)] [type (car (list-ref senv index))])
              (cond
                [(eqv? type 'normal) (nameless-var-exp index)]
                [(eqv? type 'letrec) (nameless-letrec-var-exp index)]
                [else (eopl:error 'value-of-exp "unsupported var ~s of type ~s, only allow 'normal/letrec" var type)]
                )
              )
             )
    (let-exp (var exp1 body)
             (nameless-let-exp
              (translation-of-exp exp1 senv)
              (translation-of-exp body (extend-senv-normal var senv))
              )
             )
    (proc-exp (var body)
              (nameless-proc-exp
               (translation-of-exp body (extend-senv-normal var senv))
               )
              )
    (call-exp (rator rand)
              (call-exp
               (translation-of-exp rator senv)
               (translation-of-exp rand senv)
               )
              )
    ; new stuff
    (letrec-exp (p-name b-var p-body body)
                (let ([proc-env (extend-senv-letrec p-name senv)])
                  (nameless-letrec-exp
                    ; both p-body and body remembers current senv in their env
                    ; handle recursive variable behavior in interpreter logic
                    (translation-of-exp p-body (extend-senv-normal b-var proc-env))
                    (translation-of-exp body proc-env)
                    )
                  )
                )
    (else (eopl:error 'translation-of-exp "unsupported expression type ~s" exp))
    )
  )
