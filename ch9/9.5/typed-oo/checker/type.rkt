#lang eopl

(provide (all-defined-out))

(define-datatype type type?
  (int-type)
  (bool-type)
  (proc-type (arg-type (list-of type?)) (result-type type?))
  (void-type)
  (list-type (element-type type?))
  (class-type (name symbol?))
  )

(define (type-to-external-form ty)
  (if (list? ty)
      (map type-to-external-form ty)
      (cases type ty
        (int-type () 'int)
        (bool-type () 'bool)
        (proc-type (arg-types result-type)
                   (list (type-to-external-form arg-types)
                         '->
                         (type-to-external-form result-type)
                         )
                   )
        (void-type () 'void)
        (list-type (element-type) (list 'listof (type-to-external-form element-type)))
        (class-type (class-name) class-name)
        )
      )
  )

(define (report-unequal-types ty1 ty2 exp)
  (eopl:error 'check-unequal-type! "Types didn't match: ~s != ~a in ~%~a"
              (type-to-external-form ty1)
              (type-to-external-form ty2)
              exp
              )
  )

(define (check-equal-type! ty1 ty2 exp)
  (if (not (equal? ty1 ty2))
      (report-unequal-types ty1 ty2 exp)
      #f
      )
  )
