#lang eopl

(require "type.rkt")
(provide (all-defined-out))

(define (apply-one-subst ty0 tvar ty1)
  (cases type ty0
    (int-type () (int-type))
    (bool-type () (bool-type))
    (proc-type (arg-type result-type)
               (proc-type (apply-one-subst arg-type tvar ty1) (apply-one-subst result-type tvar ty1))
               )
    (tvar-type (sn)
               (if (equal? ty0 tvar) ty1 ty0)
               )
    )
  )

(define (pair-of pred1 pred2)
  (lambda (val)
    (and (pair? val) (pred1 (car val)) (pred2 (cdr val)))
    )
  )

(define substitution? (list-of (pair-of tvar-type? type?)))

(define (apply-subst-to-type ty subst)
  (cases type ty
    (int-type () (int-type))
    (bool-type () (bool-type))
    (proc-type (arg-type result-type)
               (proc-type (apply-subst-to-type arg-type subst) (apply-subst-to-type result-type subst))
               )
    (tvar-type (sn)
               (let ([tmp (assoc ty subst)])
                 ; no-occurrence invariant is not needed anymore, cause any var at left side in subst
                 ; will be repeatedly replaced with corresponding type at right side, until ty contains
                 ; no vars in subst or a type error is found during this replacement.
                 (if tmp (apply-subst-to-type (cdr tmp) subst) ty)
                 )
               )
    )
  )

(define (empty-subst) '())

; constant time substitution extension
(define (extend-subst subst tvar ty)
  (cons
   (cons tvar ty)
   subst
   )
  )

(define (no-occurrence? tvar ty)
  (cases type ty
    (int-type () #t)
    (bool-type () #t)
    (proc-type (arg-type result-type)
               (and
                (no-occurrence? tvar arg-type)
                (no-occurrence? tvar result-type)
                )
               )
    (tvar-type (serial-number) (not (equal? tvar ty)))
    )
  )