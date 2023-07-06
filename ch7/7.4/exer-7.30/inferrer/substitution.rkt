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
    (generic-type (mono vars) (eopl:error 'apply-one-subst "generic-type not supported."))
    (void-type () (void-type))
    (ref-type (ty) (ref-type (apply-one-subst ty tvar ty1)))
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
                 (if tmp (cdr tmp) ty)
                 )
               )
    (generic-type (mono vars) (eopl:error 'apply-one-subst "generic-type not supported."))
    (void-type () (void-type))
    (ref-type (ty) (ref-type (apply-subst-to-type ty subst)))
    )
  )

(define (empty-subst) '())

; preserves no-occurrence of invariant
(define (extend-subst subst tvar ty)
  (cons
   (cons tvar ty)
   (map
    (lambda (p)
      (let ([oldlhs (car p)] [oldrhs (cdr p)])
        (cons oldlhs (apply-one-subst oldrhs tvar ty))
        )
      )
    subst)
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
    (generic-type (mono vars) (eopl:error 'apply-one-subst "generic-type not supported."))
    (void-type () #t)
    (ref-type (ty) (no-occurrence? tvar ty))
    )
  )
