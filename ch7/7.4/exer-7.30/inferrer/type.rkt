#lang eopl

(provide (all-defined-out))

(define-datatype type type?
  (int-type)
  (bool-type)
  (proc-type (arg-type type?) (result-type type?))
  (tvar-type (sn integer?))
  ; support polymorphic function only
  (generic-type (mono type?) (vars (list-of tvar-type?)))
  (void-type)
  (ref-type (type type?))
  )

(define (atomic-type? ty)
  (cases type ty
    (int-type () #t)
    (bool-type () #t)
    (else #f)
    )
  )

(define (tvar-type? ty)
  (cases type ty
    (tvar-type (sn) #t)
    (else #f)
    )
  )

(define (proc-type? ty)
  (cases type ty
    (proc-type (arg-type result-type) #t)
    (else #f)
    )
  )

(define (proc-type->arg-type ty)
  (cases type ty
    (proc-type (arg-type result-type) arg-type)
    (else (eopl:error 'proc-type->arg-type "Not a proc-type: ~s" ty))
    )
  )

(define (proc-type->result-type ty)
  (cases type ty
    (proc-type (arg-type result-type) result-type)
    (else (eopl:error 'proc-type->arg-type "Not a proc-type: ~s" ty))
    )
  )

(define (ref-type? ty)
  (cases type ty
    (ref-type (ty1) #t)
    (else #f)
    )
  )

(define (ref-type->type ty)
  (cases type ty
    (ref-type (ty1) ty1)
    (else (eopl:error 'ref-type->type "Not a ref-type: ~s" ty))
    )
  )

(define-datatype optional-type optional-type?
  (no-type)
  (a-type (ty type?))
  )

(define (otype->type otype)
  (cases optional-type otype
    (no-type () (fresh-var-type))
    (a-type (ty) ty)
    )
  )

(define sn 0)
(define (fresh-var-type)
  (set! sn (+ sn 1))
  (tvar-type sn)
  )

(define (reset-fresh-var)
  (set! sn 0)
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
    (generic-type (mono vars) (eopl:error 'generic-type "Not supported in type-to-external-form"))
    (tvar-type (serial-number)
               (string->symbol (string-append "tvar" (number->string serial-number)))
               )
    (void-type () 'void)
    (ref-type (type) (list 'ref (type-to-external-form type)))
    )
  )

(define (free-vars ty)
  (let loop ([ty ty])
    (cases type ty
      (tvar-type (sn) (list ty))
      (proc-type (arg-type result-type)
                 (append
                  (loop arg-type)
                  (loop result-type)
                  )
                 )
      (ref-type (ty) (loop ty))
      (else '())
      )
    )
  )

(define (generalize ty)
  (cases type ty
    (proc-type (arg-type result-type)
               (generic-type ty (free-vars ty))
               )
    (ref-type (ty1) (generic-type ty (free-vars ty1)))
    (else ty)
    )
  )

(define (instantiate-type ty)
  (cases type ty
    (generic-type (mono vars)
                  (replace-var-type mono (map (lambda (var) (cons var (fresh-var-type))) vars))
                  )
    (else ty)
    )
  )

(define (replace-var-type ty subst)
  (let loop ([ty ty])
    (cases type ty
      (tvar-type (sn)
                 (let ([pair (assoc ty subst)])
                   (if pair (cdr pair) ty)
                   )
                 )
      (proc-type (arg-type result-type)
                 (proc-type (loop arg-type) (loop result-type))
                 )
      (ref-type (ty)
                (ref-type (loop ty))
                )
      (else ty)
      )
    )
  )

; only ref-type is non-value in current type system
(define (is-value-type? ty)
  (cases type ty
    (ref-type (ty) #f)
    (else #t)
    )
  )
