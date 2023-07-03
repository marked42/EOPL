#lang eopl

(provide (all-defined-out))

(provide (all-defined-out))

(define-datatype type type?
  (int-type)
  (bool-type)
  (proc-type (arg-type type?) (result-type type?))
  (tvar-type (sn integer?))
  (list-type (element-type type?))
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
    (tvar-type (serial-number)
               (string->symbol (string-append "tvar" (number->string serial-number)))
               )
    (list-type (element-type) (list 'listof (type-to-external-form element-type)))
    )
  )
