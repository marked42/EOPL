#lang eopl

(require "type.rkt"
         "type-environment.rkt"
         "substitution.rkt"
         "unifier.rkt"
         "equal-up-to-gensyms.rkt"
         "../expression.rkt"
         "../parser.rkt"
         )

(provide (all-defined-out))

(define (type-of-program pgm)
  (reset-fresh-var)
  (initialize-subst!)
  (cases program pgm
    (a-program (exp1)
               (let ([ty (type-of exp1 (init-tenv))])
                 (apply-subst-to-type ty)
                 )
               )
    )
  )

(define (type-of exp tenv)
  (cases expression exp
    (const-exp (num) (int-type))
    (var-exp (var) (apply-tenv tenv var))
    (diff-exp (exp1 exp2)
              (unifier (type-of exp1 tenv) (int-type) exp1)
              (unifier (type-of exp2 tenv) (int-type) exp2)
              (int-type)
              )
    (zero?-exp (exp1)
               (unifier (type-of exp1 tenv) (int-type) exp1)
               (bool-type)
               )
    (if-exp (exp1 exp2 exp3)
            (unifier (type-of exp1 tenv) (bool-type) exp1)
            (let ([ty2 (type-of exp2 tenv)] [ty3 (type-of exp3 tenv)])
              (unifier ty2 ty3 exp)
              ty2
              )
            )
    (let-exp (var exp1 body)
             (let ([exp1-type (type-of exp1 tenv)])
                  (type-of body (extend-tenv var exp1-type tenv))
               )
             )
    (proc-exp (var otype body)
              (let ([var-type (otype->type otype)])
                (let ([result-type (type-of body (extend-tenv var var-type tenv))])
                  (proc-type var-type result-type)
                  )
                )
              )
    (call-exp (rator rand)
              (let ([result-type (fresh-var-type)]
                    [rator-type (type-of rator tenv)]
                    [rand-type (type-of rand tenv)])
                  (unifier rator-type (proc-type rand-type result-type) exp)
                  result-type
                )
              )
    (letrec-exp (p-result-otype p-name b-var b-var-otype p-body letrec-body)
                (let ([p-result-type (otype->type p-result-otype)] [b-var-type (otype->type b-var-otype)])
                  (let* ([tenv-for-letrec-body (extend-tenv p-name (proc-type b-var-type p-result-type) tenv)]
                         [p-body-type (type-of p-body (extend-tenv b-var b-var-type tenv-for-letrec-body))])
                         (unifier p-body-type p-result-type p-body)
                         (type-of letrec-body tenv-for-letrec-body)
                    )
                  )
                )
    )
  )

(define (report-rator-not-a-proc-type rator-type rator)
  (eopl:error 'type-of-expression "Rator not a proc type: ~%~s~%had rator type ~s" rator (type-to-external-form rator-type))
  )

(define (check-program-type str)
  (type-to-external-form (type-of-program (scan&parse str)))
  )
