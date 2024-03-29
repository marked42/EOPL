#lang eopl

(require racket/base "type.rkt" "type-environment.rkt" "../module.rkt" "../expression.rkt" "expand.rkt")

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
                                          [new-tenv (extend-tenv-with-module m-name expanded-iface tenv)])
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
    ; missing implementation
    [(ormap (lambda (decl2) (not (findf (lambda (decl1) (eqv? (declaration->name decl1) (declaration->name decl2))) declarations1))) declarations2) #f]
    [else
     (let loop ([declarations1 declarations1] [tenv tenv])
       (if (null? declarations1)
           #t
           (let* ([decl1 (car declarations1)]
                  [name1 (declaration->name decl1)]
                  [decl2 (findf (lambda (decl2) (eqv? (declaration->name decl2) name1)) declarations2)])
             (if decl2
                 (if (<:decl decl1 decl2 tenv)
                     (loop (cdr declarations1) (extend-tenv-with-declaration decl1 tenv))
                     #f
                     )
                 #t
                 )
             )
           )
       )
     ]
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
