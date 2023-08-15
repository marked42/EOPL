#lang eopl

(require racket/lazy-require "../expression.rkt")
(lazy-require
 ["static-environment.rkt" (
                            init-senv
                            apply-senv
                            extend-senv-normal
                            extend-senv-letrec
                            get-var-type-by-index
                            )]
 )

(provide (all-defined-out))

(define (translation-of-program prog)
  (cases program prog
    (a-program (class-decls exp1)
               (a-program
                (translation-of-class-decls class-decls (init-senv))
                (translation-of-exp exp1 (init-senv))
                )
               )
    )
  )

(define (translation-of-class-decls class-decls senv)
  ; TODO:
  class-decls
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
    (sum-exp (exp1 exp2)
             (sum-exp
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
    (call-exp (rator rands)
              (call-exp
               (translation-of-exp rator senv)
               (translation-of-exps rands senv)
               )
              )
    (begin-exp (exp1 exps)
               (begin-exp
                 (translation-of-exp exp1 senv)
                 (translation-of-exps exps senv)
                 )
               )
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
    (list-exp (exps)
              (list-exp (translation-of-exps exps senv))
              )

    ; translation
    (var-exp (var)
             (let* ([index (apply-senv senv var)] [type (get-var-type-by-index senv index)])
               (cond
                 [(eqv? type 'normal) (nameless-var-exp index)]
                 [(eqv? type 'letrec) (nameless-letrec-var-exp index)]
                 [else (eopl:error 'value-of-exp "unsupported var ~s of type ~s, only allow 'normal/letrec" var type)]
                 )
               )
             )
    (let-exp (vars exps body)
             (nameless-let-exp
              (translation-of-exps exps senv)
              (translation-of-exp body (extend-senv-normal vars senv))
              )
             )
    (proc-exp (vars body)
              (nameless-proc-exp
               (translation-of-exp body (extend-senv-normal vars senv))
               )
              )
    (assign-exp (var exp1)
                (nameless-assign-exp (apply-senv senv var) (translation-of-exp exp1 senv))
                )
    (letrec-exp (p-names b-vars p-bodies body)
                (let ([new-env (extend-senv-letrec p-names senv)])
                  (nameless-letrec-exp
                   (map (lambda (b-var p-body) (translation-of-exp p-body (extend-senv-normal (list b-var) new-env))) b-vars p-bodies)
                   (translation-of-exp body new-env)
                   )
                  )
                )

    (new-object-exp (class-name rands)
                    (new-object-exp class-name (translation-of-exps rands senv))
                    )
    (method-call-exp (obj-exp method-name rands)
                     (method-call-exp
                      (translation-of-exp obj-exp senv)
                      method-name
                      (translation-of-exps rands senv)
                      )
                     )
    (super-call-exp (method-name rands)
                    (super-call-exp method-name (translation-of-exps rands senv))
                    )
    (self-exp () (nameless-self-exp))
    (else (eopl:error 'translation-of-exp "unsupported expression type ~s" exp))
    )
  )

(define (translation-of-exps exps senv)
  (map (lambda (exp) (translation-of-exp exp senv)) exps)
  )
