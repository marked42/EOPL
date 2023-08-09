#lang eopl

(require racket/base racket/lazy-require)
(lazy-require
 ["static-class.rkt" (statically-is-subclass?)]
 )

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

(define (is-subtype? ty1 ty2)
  (cases type ty1
    (class-type (name1)
                (cases type ty2
                  (class-type (name2)
                              (statically-is-subclass? name1 name2)
                              )
                  (else #f)
                  )
                )
    (proc-type (args1 res1)
               (cases type ty2
                 (proc-type (args2 res2)
                            (and
                             (every2? is-subtype? args2 args1)
                             (is-subtype? res1 res2)
                             )
                            )
                 (else #f)
                 )
               )
    (else (equal? ty1 ty2))
    )
  )

(define every2? andmap)

(define (type->class-name ty)
  (cases type ty
    (class-type (class-name) class-name)
    (else (eopl:error 'type->class-name "Not a class type ~s." ty))
    )
  )

(define (check-is-subtype! ty1 ty2 rand)
  (if (is-subtype? ty1 ty2)
      #t
      (report-subtype-failure (type-to-external-form ty1) (type-to-external-form ty2) rand)
      )
  )

(define (report-subtype-failure external-form-ty1 external-form-ty2 exp)
  (eopl:error 'check-is-subtype!
              "~s is not a subtype of ~s in ~%~s"
              external-form-ty1
              external-form-ty2
              exp))

(define (class-type? ty)
  (cases type ty
    (class-type (name) #t)
    (else #f)
    )
  )
