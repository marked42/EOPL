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
                (translation-of-exp exp1 #f)
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
                  (a-class-decl c-name s-name f-names (translation-of-method-decls m-decls s-name))
                  )
    )
  )

(define (translation-of-method-decls m-decls s-name)
  (map (lambda (m-decl) (translation-of-method-decl m-decl s-name)) m-decls)
  )

(define (translation-of-method-decl m-decl s-name)
  (cases method-decl m-decl
    (a-method-decl (method-name vars body)
                   (a-method-decl method-name vars (translation-of-exp body s-name))
                   )
    )
  )

(define (translation-of-exp exp s-name)
  (cases expression exp
    (diff-exp (exp1 exp2)
              (diff-exp
               (translation-of-exp exp1 s-name)
               (translation-of-exp exp2 s-name)
               )
              )
    (sum-exp (exp1 exp2)
             (sum-exp
              (translation-of-exp exp1 s-name)
              (translation-of-exp exp2 s-name)
              )
             )
    (zero?-exp (exp1) (zero?-exp (translation-of-exp exp1 s-name)))
    (if-exp (exp1 exp2 exp3)
            (if-exp
             (translation-of-exp exp1 s-name)
             (translation-of-exp exp2 s-name)
             (translation-of-exp exp3 s-name)
             )
            )
    (let-exp (vars exps body)
             (let-exp vars (translation-of-exps exps s-name) (translation-of-exp body s-name))
             )
    (proc-exp (vars body)
              (proc-exp vars (translation-of-exp body s-name))
              )
    (call-exp (rator rands)
              (call-exp
               (translation-of-exp rator s-name)
               (translation-of-exps rands s-name)
               )
              )
    (letrec-exp (p-names b-vars p-bodies body)
                (letrec-exp
                 p-names
                 b-vars
                 (translation-of-exps p-bodies s-name)
                 (translation-of-exp body s-name)
                 )
                )
    (begin-exp (exp1 exps)
               (begin-exp
                 (translation-of-exp exp1 s-name)
                 (translation-of-exps exps s-name)
                 )
               )
    (assign-exp (var exp1) (assign-exp var (translation-of-exp exp1 s-name)))
    (cons-exp (exp1 exp2)
              (cons-exp
               (translation-of-exp exp1 s-name)
               (translation-of-exp exp2 s-name)
               )
              )
    (car-exp (exp1) (car-exp (translation-of-exp exp1 s-name)))
    (cdr-exp (exp1) (cdr-exp (translation-of-exp exp1 s-name)))
    (null?-exp (exp1) (null?-exp (translation-of-exp exp1 s-name)))
    (list-exp (exps) (list-exp (translation-of-exps exps s-name)))
    (new-object-exp (class-name rands)
                    (new-object-exp class-name (translation-of-exps rands s-name))
                    )
    (method-call-exp (obj-exp method-name rands)
                     (method-call-exp
                      (translation-of-exp obj-exp s-name)
                      method-name
                      (translation-of-exps rands s-name)
                      )
                     )
    (super-call-exp (method-name rands)
                    (if s-name
                        (lexical-super-call-exp
                         s-name
                         (find-method-index s-name method-name)
                         (translation-of-exps rands s-name)
                         )
                        (eopl:pretty-print 'translation-of-exp "Super call outside method is invalid, cannot be translated!")
                        )
                    )
    (else exp)
    )
  )

(define (translation-of-exps exps s-name)
  (map (lambda (exp) (translation-of-exp exp s-name)) exps)
  )
