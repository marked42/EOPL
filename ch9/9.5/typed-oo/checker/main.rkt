#lang eopl

(require racket/lazy-require racket/list "type.rkt" "../expression.rkt" "type-environment.rkt" "static-class.rkt")
(lazy-require
 ["type.rkt" (type->class-name check-is-subtype! class-type? list-type->element-type list-type?)]
 )

(provide (all-defined-out))

(define (type-of-program pgm)
  (cases program pgm
    (a-program (class-decls exp1)
               (initialize-static-class-env! class-decls)
               (for-each check-class-decl! class-decls)
               (type-of exp1 (init-tenv))
               )
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
    (sum-exp (exp1 exp2)
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
    (proc-exp (vars var-types body)
              (let ([result-type (type-of body (extend-tenv* vars var-types tenv))])
                (proc-type var-types result-type)
                )
              )
    (call-exp (rator rands)
              (let ([rator-type (type-of rator tenv)]
                    [rand-types (type-of-exps rands tenv)])
                (type-of-call rator-type rand-types rands exp)
                )
              )
    (letrec-exp (p-result-types p-names b-vars-list b-var-types-list p-bodies letrec-body)
                (let ([tenv-for-letrec-body (extend-tenv* p-names (get-proc-types b-var-types-list p-result-types) tenv)])
                  (check-p-body-types p-result-types b-vars-list b-var-types-list p-bodies tenv-for-letrec-body)
                  (type-of letrec-body tenv-for-letrec-body)
                  )
                )
    (begin-exp (exp1 exps)
               (type-of (last (cons exp1 exps)) tenv)
               )
    (assign-exp (var exp1)
                (let ([ty1 (type-of exp1 tenv)] [var-type (apply-tenv tenv var)])
                  (check-is-subtype! ty1 var-type exp)
                  (void-type)
                  )
                )
    ; list
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
    (car-exp (exp1)
             (let ([ty1 (type-of exp1 tenv)])
              (list-type->element-type ty1)
              )
             )
    (cdr-exp (exp1)
             (let ([ty1 (type-of exp1 tenv)])
              (if (list-type? ty1)
                ty1
                (eopl:error 'type-of "Operand of cdr is not list type in ~s" exp1)
                )
              )
             )
    (list-exp (exp1 exps)
              (let ([type1 (type-of exp1 tenv)])
                ; requires every element type to be same
                (map (lambda (exp) (check-equal-type! (type-of exp tenv) type1 exp)) exps)
                (list-type type1)
                )
              )

    ; class
    (new-object-exp (class-name rands)
                    (let ([arg-types (type-of-exps rands tenv)] [c (lookup-static-class class-name)])
                      (cases static-class c
                        (an-interface (method-tenv)
                                      (report-cant-instantiate-interface class-name)
                                      )
                        (a-static-class (super-name i-names field-names field-types method-tenv)
                                        (type-of-call
                                         (find-method-type class-name 'initialize)
                                         arg-types
                                         rands
                                         exp
                                         )
                                        (class-type class-name)
                                        )
                        )
                      )
                    )
    (method-call-exp (obj-exp method-name rands)
                     (let ([arg-types (type-of-exps rands tenv)] [obj-type (type-of obj-exp tenv)])
                       (type-of-call
                        (find-method-type (type->class-name obj-type) method-name)
                        arg-types
                        rands
                        exp
                        )
                       )
                     )
    (super-call-exp (method-name rands)
                    (let ([arg-types (type-of-exps rands tenv)])
                      (type-of-call
                       (find-method-type (apply-tenv tenv '%super) method-name)
                       arg-types
                       rands
                       exp
                       )
                      )
                    )

    (self-exp () (apply-tenv tenv '%self))

    (cast-exp (obj-exp class-name)
              (let ([obj-type (type-of obj-exp tenv)])
                ; TODO: not checking obj-type is subtype of class
                (if (class-type? obj-type)
                    (class-type class-name)
                    (report-bad-type-to-cast obj-type exp)
                    )
                )
              )
    (instanceof-exp (obj-exp class-name)
                    (let ([obj-type (type-of obj-exp tenv)])
                      ; TODO: not checking obj-type is subtype of class
                      (if (class-type? obj-type)
                          (bool-type)
                          (report-bad-type-to-instanceof obj-type exp)
                          )
                      )
                    )

    (else (eopl:error 'type-of "Not checking OO now."))
    )
  )

(define (report-rator-not-a-proc-type rator-type rator)
  (eopl:error 'type-of-expression "Rator not a proc type: ~%~s~%had rator type ~s" rator (type-to-external-form rator-type))
  )

(define (type-of-exps exps tenv)
  (map (lambda (exp) (type-of exp tenv)) exps)
  )

(define (get-proc-types b-var-types-list p-result-types)
  (map (lambda (b-var-types p-result-type) (proc-type b-var-types p-result-type)) b-var-types-list p-result-types)
  )

(define (check-p-body-types p-result-types b-vars-list b-var-types-list p-bodies tenv-for-letrec-body)
  (map
   (lambda (p-result-type b-vars b-var-types p-body)
     (let ([p-body-type (type-of p-body (extend-tenv* b-vars b-var-types tenv-for-letrec-body))])
       (check-equal-type! p-body-type p-result-type p-body)
       )
     )
   p-result-types
   b-vars-list
   b-var-types-list
   p-bodies
   )
  )

(define (type-of-call rator-type rand-types rands exp)
  (cases type rator-type
    (proc-type (arg-types result-type)
               (if (not (= (length arg-types) (length rand-types)))
                   (report-wrong-number-of-arguments
                    (map type-to-external-form arg-types)
                    (map type-to-external-form rand-types)
                    exp
                    )
                   (for-each check-is-subtype! rand-types arg-types rands)
                   )
               result-type
               )
    (else (report-rator-not-of-proc-type (type-to-external-form rator-type) exp))
    )
  )

(define (report-wrong-number-of-arguments arg-types rand-types exp)
  (eopl:error 'type-of-call
              "These are not the same: ~s and ~s in ~s"
              (map type-to-external-form arg-types)
              (map type-to-external-form rand-types)
              exp)
  )

(define (report-rator-not-of-proc-type rator-type exp)
  (eopl:error 'type-of-call
              "rator ~s is not of proc-type ~s"
              exp
              rator-type)
  )

(define (report-cant-instantiate-interface class-name)
  (eopl:error 'type-of-new-obj-exp "Can't instantiate interface ~s" class-name)
  )

(define (report-bad-type-to-cast type exp)
  (eopl:error 'bad-type-to-case
              "can't cast non-object; ~s had type ~s"
              exp
              (type-to-external-form type)
              )
  )

(define (report-bad-type-to-instanceof type exp)
  (eopl:error 'bad-type-to-case
              "can't apply instanceof to non-object; ~s had type ~s"
              exp
              (type-to-external-form type)
              )
  )
