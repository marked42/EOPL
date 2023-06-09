#lang eopl

(require "type.rkt" "../expression.rkt" "type-environment.rkt" "../typed-var.rkt")

(provide (all-defined-out))

(define (type-of-program pgm)
  (cases program pgm
    (a-program (exp1) (type-of exp1 (init-tenv)))
    )
  )

(define (type-of exp tenv)
  (cases expression exp
    (const-exp (num) (int-type))
    (var-exp (var) (apply-tenv tenv var))
    (diff-exp (exp1 exp2)
              (let ([ty1 (type-of exp1 tenv)] [ty2 (type-of exp2 tenv)])
                (check-equal-type! ty1 (int-type) exp1)
                (check-equal-type! ty2 (int-type) exp2)
                (int-type)
                )
              )
    (zero?-exp (exp1)
               (let ([ty1 (type-of exp1 tenv)])
                 (check-equal-type! ty1 (int-type) exp1)
                 (bool-type)
                 )
               )
    (if-exp (exp1 exp2 exp3)
            (let ([ty1 (type-of exp1 tenv)]
                  [ty2 (type-of exp2 tenv)]
                  [ty3 (type-of exp3 tenv)]
                  )
              (check-equal-type! ty1 (bool-type) exp1)
              (check-equal-type! ty2 ty3 exp)
              ty2
              )
            )
    (let-exp (vars exps body)
             (let ([var-types (type-of-exps exps tenv)])
               (type-of body (extend-tenv* vars var-types tenv))
               )
             )
    (proc-exp (typed-vars body)
              (let ([vars (typed-vars->vars typed-vars)] [var-types (typed-vars->types typed-vars)])
                (let ([result-type (type-of body (extend-tenv* vars var-types tenv))])
                  (proc-type var-types result-type)
                  )
                )
              )
    (call-exp (rator rands)
              (let ([rator-type (type-of rator tenv)]
                    [rand-types (type-of-exps rands tenv)])
                (cases type rator-type
                  (proc-type (arg-type result-type)
                             (begin
                               (check-equal-type! arg-type rand-types rands)
                               result-type
                               )
                             )
                  (else (report-rator-not-a-proc-type rator-type rator))
                  )
                )
              )
    (letrec-exp (p-result-type p-name b-var b-var-type p-body letrec-body)
                (let ([tenv-for-letrec-body (extend-tenv* (list p-name) (list (proc-type (list b-var-type) p-result-type)) tenv)])
                  (let ([p-body-type (type-of p-body (extend-tenv* (list b-var) (list b-var-type) tenv-for-letrec-body))])
                    (check-equal-type! p-body-type p-result-type p-body)
                    (type-of letrec-body tenv-for-letrec-body)
                    )
                  )
                )
    )
  )

(define (report-rator-not-a-proc-type rator-type rator)
  (eopl:error 'type-of-expression "Rator not a proc type: ~%~s~%had rator type ~s" rator (type-to-external-form rator-type))
  )

(define (type-of-exps exps tenv)
  (map (lambda (exp) (type-of exp tenv)) exps)
  )
