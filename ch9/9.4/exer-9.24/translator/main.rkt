#lang eopl

(require racket/lazy-require "../expression.rkt")
(lazy-require
 ["static-class.rkt" (initialize-class-env! find-method-index)]
 )

(provide (all-defined-out))

(define (translation-of-program prog)
  (cases program prog
    (a-program (class-decls exp1)
               (initialize-class-env! class-decls)
               (a-program
                (translation-of-class-decls class-decls)
                (translation-of-exp exp1)
                )
               )
    )
  )

(define (translation-of-class-decls class-decls)
  (map translation-of-class-decl class-decls)
  )

(define (translation-of-class-decl c-decl)
  (cases class-decl c-decl
    (a-class-decl (c-name s-name f-names m-decls)
                  (a-class-decl c-name s-name f-names (translation-of-method-decls m-decls))
                  )
    )
  )

(define (translation-of-method-decls m-decls)
  (map translation-of-method-decl m-decls)
  )

(define (translation-of-method-decl m-decl)
  (cases method-decl m-decl
    (a-method-decl (method-name vars body)
                   (a-method-decl method-name vars (translation-of-exp body))
                   )
    )
  )

(define (translation-of-exp exp)
  (cases expression exp
    (diff-exp (exp1 exp2)
              (diff-exp
               (translation-of-exp exp1)
               (translation-of-exp exp2)
               )
              )
    (sum-exp (exp1 exp2)
             (sum-exp
              (translation-of-exp exp1)
              (translation-of-exp exp2)
              )
             )
    (zero?-exp (exp1) (zero?-exp (translation-of-exp exp1)))
    (if-exp (exp1 exp2 exp3)
            (if-exp
             (translation-of-exp exp1)
             (translation-of-exp exp2)
             (translation-of-exp exp3)
             )
            )
    (let-exp (vars exps body)
             (let-exp vars (translation-of-exps exps) (translation-of-exp body))
             )
    (proc-exp (vars body)
              (proc-exp vars (translation-of-exp body))
              )
    (call-exp (rator rands)
              (call-exp
               (translation-of-exp rator)
               (translation-of-exps rands)
               )
              )
    (letrec-exp (p-names b-vars p-bodies body)
                (letrec-exp
                 p-names
                 b-vars
                 (translation-of-exps p-bodies)
                 (translation-of-exp body)
                 )
                )
    (begin-exp (exp1 exps)
               (begin-exp
                 (translation-of-exp exp1)
                 (translation-of-exps exps)
                 )
               )
    (assign-exp (var exp1) (assign-exp var (translation-of-exp exp1)))
    (cons-exp (exp1 exp2)
              (cons-exp
               (translation-of-exp exp1)
               (translation-of-exp exp2)
               )
              )
    (car-exp (exp1) (car-exp (translation-of-exp exp1)))
    (cdr-exp (exp1) (cdr-exp (translation-of-exp exp1)))
    (null?-exp (exp1) (null?-exp (translation-of-exp exp1)))
    (list-exp (exps) (list-exp (translation-of-exps exps)))
    (new-object-exp (class-name rands)
                    (new-object-exp class-name (translation-of-exps rands))
                    )
    (method-call-exp (obj-exp method-name rands)
                     (method-call-exp
                      (translation-of-exp obj-exp)
                      method-name
                      (translation-of-exps rands)
                      )
                     )
    (super-call-exp (method-name rands)
                    (super-call-exp
                     method-name
                     (translation-of-exps rands)
                     )
                    )
    (named-fieldref-exp (class-name obj-exp field-name)
                        (named-fieldref-exp
                         class-name
                         (translation-of-exp obj-exp)
                         field-name
                         )
                        )
    (named-fieldset-exp (class-name obj-exp field-name value)
                        (named-fieldset-exp
                         class-name
                         (translation-of-exp obj-exp)
                         field-name
                         (translation-of-exp value)
                         )
                        )

    (named-method-call-exp (class-name obj-exp method-name rands)
                           ; translate method-name to method index for constant time method searching
                           (lexical-named-method-call-exp
                            class-name
                            (translation-of-exp obj-exp)
                            (find-method-index class-name method-name)
                            (translation-of-exps rands)
                            )
                           )
    (else exp)
    )
  )

(define (translation-of-exps exps)
  (map translation-of-exp exps)
  )
