#lang eopl

(require "type.rkt" "type-environment.rkt" "../module.rkt" "../expression.rkt")

(provide (all-defined-out))

(define (type-of-program pgm)
  (cases program pgm
    (a-program (m-defs body)
               (let ([tenv (add-module-definitions-to-tenv m-defs (empty-tenv))])
                 (type-of body tenv)
                 )
               )
    )
  )

(define (add-module-definitions-to-tenv defs tenv)
  (if (null? defs)
      tenv
      (cases module-definition (car defs)
        (a-module-definition (m-name expected-interface m-body)
                             (let ([actual-interface (interface-of m-body tenv)])
                               (if (<:iface actual-interface expected-interface tenv)
                                   (let ([new-tenv (extend-tenv-with-module m-name expected-interface tenv) ])
                                     (add-module-definitions-to-tenv (cdr defs) new-tenv)
                                     )
                                   (report-module-doesnt-satisfy-iface m-name expected-interface actual-interface)
                                   )
                               )
                             )
        )
      )
  )

(define (interface-of m-body tenv)
  (cases module-body m-body
    (definitions-module-body (definitions)
      (simple-interface (definitions-to-declarations definitions tenv))
      )
    )
  )

(define (definitions-to-declarations definitions tenv)
  (if (null? definitions)
      '()
      (cases definition (car definitions)
        (val-definition (var-name exp)
                        (let ([ty (type-of exp tenv)])
                          (cons
                           (var-declaration var-name ty)
                           (definitions-to-declarations
                             (cdr definitions)
                             ; let* scoping rule
                             (extend-tenv* (list var-name) (list ty) tenv)
                             )
                           )
                          )
                        )
        )
      )
  )

(define (<:iface iface1 iface2 tenv)
  (cases interface iface1
    (simple-interface (declarations1)
                      (cases interface iface2
                        (simple-interface (declarations2)
                                          (<:decls declarations1 declarations2 tenv)
                                          )
                        )
                      )
    )
  )

(define (report-module-doesnt-satisfy-iface m-name expected-type actual-type)
  (eopl:pretty-print
   (list 'error-in-definition-of-module: m-name
         'expected-type: expected-type
         'actual-type: actual-type))
  (eopl:error 'type-of-module-definition)
  )

(define (<:decls declarations1 declarations2 tenv)
  (cond
    [(null? declarations2) #t]
    [(null? declarations1) #f]
    (else (let* ([decl1 (car declarations1)]
                 [name1 (decl->name decl1)]
                 [decl2 (car declarations2)]
                 [name2 (decl->name decl2)]
                 )
            (if (eqv? name1 name2)
                (and
                 (equal? (decl->type decl1) (decl->type decl2))
                 (<:decls (cdr declarations1) (cdr declarations2) tenv)
                 )
                (<:decls (cdr declarations1) declarations2 tenv)
                )
            )
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
             (let ([types (type-of-exps exps tenv)])
               (type-of body (extend-tenv* vars types tenv))
               )
             )
    (proc-exp (params body)
              (let* ([var-types (map parameter->var params)]
                     [var-names (map parameter->type params)]
                     [result-type (type-of body (extend-tenv* var-names var-types tenv))])
                (proc-type var-types result-type)
                )
              )
    (call-exp (rator rands)
              (let ([rator-type (type-of rator tenv)]
                    [rand-types (type-of-exps rands tenv)])
                (cases type rator-type
                  (proc-type (arg-types result-type)
                             (begin
                               (map check-equal-type! arg-types rand-types rands)
                               result-type
                               )
                             )
                  (else (report-rator-not-a-proc-type rator-type rator))
                  )
                )
              )
    (letrec-exp (p-result-types p-names b-vars b-var-types p-bodies letrec-body)
                (let ([tenv-for-letrec-body (extend-tenv* p-names (map get-letrec-proc-type b-var-types p-result-types) tenv)])
                  (map
                   (lambda (p-result-type b-var b-var-type p-body)
                     (let ([p-body-type (type-of p-body (extend-tenv* (list b-var) (list b-var-type) tenv-for-letrec-body))])
                       (check-equal-type! p-body-type p-result-type p-body)
                       )
                     )
                   p-result-types
                   b-vars
                   b-var-types
                   p-bodies
                   )

                  (type-of letrec-body tenv-for-letrec-body)
                  )
                )
    (qualified-var-exp (m-name var-name)
                       (lookup-qualified-var-in-tenv m-name var-name tenv)
                       )
    )
  )

(define (get-letrec-proc-type b-var-type p-result-type)
  (proc-type (list b-var-type) p-result-type)
  )

(define (report-rator-not-a-proc-type rator-type rator)
  (eopl:error 'type-of-expression "Rator not a proc type: ~%~s~%had rator type ~s" rator (type-to-external-form rator-type))
  )

(define (type-of-exps exps tenv)
  (map (lambda (exp) (type-of exp tenv)) exps)
  )
