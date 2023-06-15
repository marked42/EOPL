#lang eopl

(require "type.rkt" "../expression.rkt" "type-environment.rkt")

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
    (let-exp (var exp1 body)
             (let ([exp1-type (type-of exp1 tenv)])
               (type-of body (extend-tenv var exp1-type tenv))
               )
             )
    (proc-exp (var var-type body)
              (let ([result-type (type-of body (extend-tenv var var-type tenv))])
                (proc-type var-type result-type)
                )
              )
    (call-exp (rator rand)
              (let ([rator-type (type-of rator tenv)]
                    [rand-type (type-of rand tenv)])
                (cases type rator-type
                  (proc-type (arg-type result-type)
                             (begin
                               (check-equal-type! arg-type rand-type rand)
                               result-type
                               )
                             )
                  (else (report-rator-not-a-proc-type rator-type rator))
                  )
                )
              )
    (letrec-exp (p-result-type p-name b-var b-var-type p-body letrec-body)
                (let ([tenv-for-letrec-body (extend-tenv p-name (proc-type b-var-type p-result-type) tenv)])
                  (let ([p-body-type (type-of p-body (extend-tenv b-var b-var-type tenv-for-letrec-body))])
                    (check-equal-type! p-body-type p-result-type p-body)
                    (type-of letrec-body tenv-for-letrec-body)
                    )
                  )
                )
    ; new stuff
    (emptylist-exp (element-type)
                   (list-type element-type)
                   )
    (null?-exp (exp1)
               (let ([exp1-type (type-of exp1 tenv)])
                 (cases type exp1-type
                   (list-type (element-type) (bool-type))
                   (else (eopl:error 'type-of "null? requires exp1 to be list type, get ~s" exp1-type))
                   )
                 )
               )
    (cons-exp (exp1 exp2)
              (let ([type1 (type-of exp1 tenv)] [type2 (type-of exp2 tenv)])
                (check-equal-type! (list-type type1) type2 exp)
                type2
                )
              )
    )
  )

(define (report-rator-not-a-proc-type rator-type rator)
  (eopl:error 'type-of-expression "Rator not a proc type: ~%~s~%had rator type ~s" rator (type-to-external-form rator-type))
  )
