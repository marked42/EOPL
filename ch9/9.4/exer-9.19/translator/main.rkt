#lang eopl

(require racket/lazy-require "../expression.rkt")
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
    (assign-exp (var exp1)
                (let* ([index (apply-senv senv var)] [depth (car index)] [offset (cdr index)])
                  (nameless-assign-exp
                   depth
                   offset
                   (translation-of-exp exp1 senv)
                   )
                  )
                )
    (else (eopl:error 'translation-of-exp "unsupported expression type ~s" exp))
    )
  )

(define (translation-of-exps exps senv)
  (map (lambda (exp) (translation-of-exp exp senv)) exps)
  )
