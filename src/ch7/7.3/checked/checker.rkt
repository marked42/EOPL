#lang eopl

(require "expression.rkt" "basic.rkt" "grammar.rkt")

(provide (all-defined-out))

(define-datatype type-environment type-environment?
  (empty-tenv)
  (extend-tenv
   (var identifier?)
   (type type?)
   (tenv type-environment?)
   )
  )

(define (init-tenv)
  (extend-tenv 'i (int-type)
               (extend-tenv 'v (int-type)
                            (extend-tenv 'x (int-type)
                                         (empty-tenv)
                                         )
                            )
               )
  )

(define (apply-tenv env search-var)
  (cases type-environment env
    (extend-tenv (var type saved-env)
                 (if (eqv? search-var var)
                     type
                     (apply-tenv saved-env search-var)
                     )
                 )
    (else (report-no-binding-found search-var))
    )
  )


(define (report-unequal-types ty1 ty2 exp)
  (eopl:error 'check-unequal-type! "Types didn't match: ~s != ~a in ~%~a"
              (type-to-external-form ty1)
              (type-to-external-form ty2)
              exp
              )
  )

(define (type-to-external-form ty)
  (cases type ty
    (int-type () 'int)
    (bool-type () 'bool)
    (proc-type (arg-type result-type)
               (list (type-to-external-form arg-type)
                     '->
                     (type-to-external-form result-type)
                     )
               )
    )
  )

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
              (let ((ty1 (type-of exp1 tenv)) (ty2 (type-of exp2 tenv)))
                (check-equal-type! ty1 (int-type) exp1)
                (check-equal-type! ty2 (int-type) exp2)
                (int-type)
                )
              )
    (zero?-exp (exp1)
               (let ((ty1 (type-of exp1 tenv)))
                 (check-equal-type! ty1 (int-type) exp1)
                 (bool-type)
                 )
               )
    (if-exp (exp1 exp2 exp3)
            (let ((ty1 (type-of exp1 tenv))
                  (ty2 (type-of exp2 tenv))
                  (ty3 (type-of exp3 tenv))
                  )
              (check-equal-type! ty1 (bool-type) exp1)
              (check-equal-type! ty2 ty3 exp)
              ty2
              )
            )
    (let-exp (var exp1 body)
             (let ((exp1-type (type-of exp1 tenv)))
               (type-of body (extend-tenv var exp1-type tenv))
               )
             )
    (proc-exp (var var-type body)
              (let ((result-type (type-of body (extend-tenv var var-type tenv))))
                (proc-type var-type result-type)
                )
              )
    (call-exp (rator rand)
              (let ((rator-type (type-of rator tenv))
                    (rand-type (type-of rand tenv)))
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
                (let ((tenv-for-letrec-body (extend-tenv p-name (proc-type b-var-type p-result-type) tenv)))
                  (let ((p-body-type (type-of p-body (extend-tenv b-var b-var-type tenv-for-letrec-body))))
                    (check-equal-type! p-body-type p-result-type p-body)
                    (type-of letrec-body tenv-for-letrec-body)
                    )
                  )
                )
    )
  )

(define (check-equal-type! ty1 ty2 exp)
  (if (not (equal? ty1 ty2))
      (report-unequal-types ty1 ty2 exp)
      #f
      )
  )

(define (report-rator-not-a-proc-type rator-type rator)
  (eopl:error 'type-of-expression "Rator not a proc type: ~%~s~%had rator type ~s" rator (type-to-external-form rator-type))
  )