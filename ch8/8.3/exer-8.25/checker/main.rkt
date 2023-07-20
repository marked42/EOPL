#lang eopl

(require "type.rkt" "type-environment.rkt" "../module.rkt" "../expression.rkt" "expand.rkt" "renaming.rkt")

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
                                   ; expand interfaces
                                   (let* ([expanded-iface (expand-iface m-name expected-interface tenv)]
                                          [new-tenv (extend-tenv-with-module (list m-name) (list expanded-iface) tenv)])
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
    (var-module-body (m-name)
                     (lookup-module-name-in-tenv tenv m-name)
                     )
    (proc-module-body (rand-name rand-iface m-body)
                      (let* ([expanded-iface (expand-iface rand-name rand-iface tenv)]
                             [new-env (extend-tenv-with-module (list rand-name) (list expanded-iface) tenv)]
                             [body-iface (interface-of m-body new-env)])
                        (proc-interface rand-name rand-iface body-iface)
                        )
                      )
    (app-module-body (rator-id rand-id)
                     (let ([rator-iface (lookup-module-name-in-tenv tenv rator-id)]
                           [rand-iface (lookup-module-name-in-tenv tenv rand-id)])
                       (cases interface rator-iface
                         (simple-interface (decls)
                                           (report-attempt-to-apply-simple-module rator-id)
                                           )
                         (proc-interface (param-name param-iface result-iface)
                                         (if (<:iface rand-iface param-iface tenv)
                                             (rename-in-iface result-iface (list param-name) (list rand-id))
                                             (report-bad-module-application-error param-iface rand-iface m-body)
                                             )
                                         )
                         )
                       )
                     )
    )
  )

(define (report-attempt-to-apply-simple-module name)
  (eopl:error 'report-attempt-to-apply-simple-module "Cannot apply simple module ~s" name)
  )

(define (report-bad-module-application-error param-iface rand-iface m-body)
  (eopl:pretty-print
   (list 'param-iface: param-iface
         'rand-iface: rand-iface
         'm-body: m-body))
  (eopl:error 'report-bad-module-application-error)
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
                             (extend-tenv var-name ty tenv)
                             )
                           )
                          )
                        )
        (type-definition (var-name ty)
                         (let ([new-env (extend-tenv-with-type var-name (expand-type ty tenv) tenv)])
                           (cons
                            (transparent-type-declaration var-name ty)
                            (definitions-to-declarations (cdr definitions) new-env)
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
                        (proc-interface (param-name param-iface result-iface) #f)
                        )
                      )
    (proc-interface (param-name1 param-iface1 result-iface1)
                    (cases interface iface2
                      (simple-interface (decls2) #f)
                      (proc-interface (param-name2 param-iface2 result-iface2)
                                      (let* ([new-name (fresh-module-name param-name1)]
                                             [result-iface1 (rename-in-iface result-iface1 (list param-name1) (list new-name))]
                                             [result-iface2 (rename-in-iface result-iface2 (list param-name2) (list new-name))])
                                        (and
                                         ; parameter type contra-variant
                                         (<:iface param-iface2 param-iface1 tenv)
                                         ; result type covariant
                                         (<:iface result-iface1 result-iface2
                                                  (extend-tenv-with-module
                                                   (list new-name)
                                                   (list (expand-iface new-name param-iface1 tenv))
                                                   tenv
                                                   ))
                                         )
                                        )
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
                 [name1 (declaration->name decl1)]
                 [decl2 (car declarations2)]
                 [name2 (declaration->name decl2)]
                 )
            (if (eqv? name1 name2)
                (and
                 (<:decl (car declarations1) (car declarations2) tenv)
                 (<:decls (cdr declarations1) (cdr declarations2) (extend-tenv-with-declaration (car declarations1) tenv))
                 )
                (<:decls (cdr declarations1) declarations2 (extend-tenv-with-declaration (car declarations1) tenv))
                )
            )
          )
    )
  )

(define (<:decl decl1 decl2 tenv)
  (or
   (and
    (var-declaration? decl1)
    (var-declaration? decl2)
    (equiv-type? (declaration->type decl1) (declaration->type decl2) tenv)
    )
   (and
    (transparent-type-declaration? decl1)
    (transparent-type-declaration? decl2)
    (equiv-type? (declaration->type decl1) (declaration->type decl2) tenv)
    )
   (and
    (transparent-type-declaration? decl1)
    (opaque-type-declaration? decl2)
    )
   (and
    (opaque-type-declaration? decl1)
    (opaque-type-declaration? decl2)
    )
   )
  )

(define (equiv-type? ty1 ty2 tenv)
  (equal?
   (expand-type ty1 tenv)
   (expand-type ty2 tenv)
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
               (type-of body (extend-tenv var (expand-type exp1-type tenv) tenv))
               )
             )
    (proc-exp (var var-type body)
              (let* ([expanded-var-type (expand-type var-type tenv)]
                     [result-type (type-of body (extend-tenv var expanded-var-type tenv))])
                (proc-type expanded-var-type result-type)
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
                (let ([tenv-for-letrec-body (extend-tenv p-name (expand-type (proc-type b-var-type p-result-type) tenv) tenv)])
                  (let ([p-body-type (type-of p-body (extend-tenv b-var (expand-type b-var-type tenv-for-letrec-body) tenv-for-letrec-body))])
                    (check-equal-type! p-body-type p-result-type p-body)
                    (type-of letrec-body tenv-for-letrec-body)
                    )
                  )
                )
    (qualified-var-exp (m-name var-name)
                       (lookup-qualified-type-in-tenv m-name var-name tenv)
                       )
    )
  )

(define (report-rator-not-a-proc-type rator-type rator)
  (eopl:error 'type-of-expression "Rator not a proc type: ~%~s~%had rator type ~s" rator (type-to-external-form rator-type))
  )
