#lang eopl

(require racket/string)

(provide (all-defined-out))

(define-datatype type type?
  (int-type)
  (bool-type)
  (proc-type (arg-type type?) (result-type type?))
  (module-type (vars (list-of symbol?)) (types (list-of type?)))
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
    (module-type (vars types)
                 (string-append
                  "["
                  (string-join
                   (map var-declaration-to-external-form vars types)
                   " "
                   )
                  "]"
                  )
                 )
    )
  )

(define (var-declaration-to-external-form var ty)
  (string-append
   (symbol->string var)
   " : "
   (type-to-external-form ty)
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
