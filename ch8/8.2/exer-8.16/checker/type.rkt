#lang eopl

(provide (all-defined-out))

(define-datatype type type?
  (int-type)
  (bool-type)
  (proc-type (arg-types (list-of type?)) (result-type type?))
  (named-type (name symbol?))
  (qualified-type (m-name symbol?) (t-name symbol?))
  )

(define (type-to-external-form ty)
  (cases type ty
    (int-type () 'int)
    (bool-type () 'bool)
    (proc-type (arg-types result-type)
               (append
                (map type-to-external-form arg-types)
                (list '-> (type-to-external-form result-type))
                )
    )
    (named-type (name) name)
    (qualified-type (m-name t-name) (list 'from m-name 'take t-name))
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
