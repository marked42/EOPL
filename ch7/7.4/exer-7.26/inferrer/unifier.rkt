#lang eopl

(require "substitution.rkt" "type.rkt")

(provide (all-defined-out))

(define (unifier ty1 ty2 subst exp)
  (let ([ty1 (apply-subst-to-type ty1 subst)] [ty2 (apply-subst-to-type ty2 subst)])
    (cond
      [(equal? ty1 ty2) subst]
      [(tvar-type? ty1)
       (if (no-occurrence? ty1 ty2)
           (extend-subst subst ty1 ty2)
           (report-no-occurrence-violation ty1 ty2 exp)
           )
       ]
      [(tvar-type? ty2)
       (if (no-occurrence? ty2 ty1)
           (extend-subst subst ty2 ty1)
           (report-no-occurrence-violation ty2 ty1 exp)
           )
       ]
      [(and (proc-type? ty1) (proc-type? ty2))
       (let ([subst (unifier (proc-type->arg-type ty1) (proc-type->arg-type ty2) subst exp)])
         (let ([subst (unifier (proc-type->result-type ty1) (proc-type->result-type ty2) subst exp)])
           subst
           )
         )
       ]
      [(and (ref-type? ty1) (ref-type? ty2))
       (let ([subst (unifier (ref-type->type ty1) (ref-type->type ty2) subst exp)])
         subst
         )
       ]
      [else (report-unification-failure ty1 ty2 exp)]
      )
    )
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
