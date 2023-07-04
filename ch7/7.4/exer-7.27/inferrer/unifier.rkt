#lang eopl

(require racket/list "substitution.rkt" "type.rkt" "../expression.rkt")

(provide (all-defined-out))

(define (unify equations)
  (let loop ([equations equations] [subst '()])
    (if (null? equations)
        subst
        (let* ([next-equation (car equations)]
               [ty1 (first next-equation)]
               [ty2 (second next-equation)]
               [exp (third next-equation)])
          (let ([ty1 (apply-subst-to-type ty1 subst)] [ty2 (apply-subst-to-type ty2 subst)])
            (cond
              [(equal? ty1 ty2) (loop (cdr equations) subst)]
              [(tvar-type? ty1)
               (if (no-occurrence? ty1 ty2)
                   ; new substitutions found
                   (loop (cdr equations) (extend-subst subst ty1 ty2))
                   (report-no-occurrence-violation ty1 ty2 exp)
                   )
               ]
              [(tvar-type? ty2)
               (if (no-occurrence? ty2 ty1)
                   ; new substitutions found
                   (loop (cdr equations) (extend-subst subst ty2 ty1))
                   (report-no-occurrence-violation ty2 ty1 exp)
                   )
               ]
              [(and (proc-type? ty1) (proc-type? ty2))
               ; new equations added
               (let ([equations
                      (extend-equations
                       (proc-type->arg-type ty1)
                       (proc-type->arg-type ty2)
                       (extend-equations
                        (proc-type->result-type ty1)
                        (proc-type->result-type ty2)
                        equations
                        exp
                        )
                       exp
                       )
                      ])
                 (loop equations subst)
                 )
               ]
              [else (report-unification-failure ty1 ty2 exp)]
              )
            )
          )
        )
    )
  )

(define equations? (list-of (lambda (val)
                              (and
                               (list? val)
                               (type? (first val))
                               (type? (second val))
                               (expression? (third val))
                               )
                              )))

(define (empty-equations) '())

(define (extend-equations ty1 ty2 equations exp)
  (cons (list ty1 ty2 exp) equations)
  )

(define (report-no-occurrence-violation ty1 ty2 exp)
  (eopl:error
   'check-no-occurence!
   		"Can't unify: type variable ~s occurs in type ~s in expression ~s~%"
                		(type-to-external-form ty1)
                                		(type-to-external-form ty2)
                                                		exp)
  )

(define (report-unification-failure ty1 ty2 exp)
  (eopl:error
   'unification-failure
   		"Type mismatch: ~s doesn't match ~s in ~s~%"
                		(type-to-external-form ty1)
                                		(type-to-external-form ty2)
                                                		exp
                                                                )
  )
