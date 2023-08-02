#lang eopl

(require racket/lazy-require racket/list "expression.rkt")
(lazy-require
 ["value.rkt" (num-val expval? proc-val)]
 ["store.rkt" (reference? newref)]
 ["procedure.rkt" (procedure)]
 ["object.rkt" (object?)]
 ["class.rkt" (
               a-class
               create-a-class
               report-unknown-class-name
               class?
               )]
 )
(provide (all-defined-out))

(define-datatype environment environment?
  (empty-env)
  (extend-env*
   (vars (list-of symbol?))
   (vals (list-of reference?))
   (saved-env environment?)
   )
  (extend-env-rec*
   (p-names (list-of symbol?))
   (b-vars (list-of symbol?))
   (p-bodies (list-of expression?))
   (saved-env environment?)
   )
  (extend-env-with-class
   (class-name symbol?)
   (a-class class?)
   (saved-env environment?)
   )
  (extend-env-with-self-and-super
   (self object?)
   (super-name symbol?)
   (saved-env environment?)
   )
  )

(define (init-env)
  ; new stuff
  (extend-env*
   (list 'i 'v 'x)
   (list (newref (num-val 1)) (newref (num-val 5)) (newref (num-val 10)))
   (extend-env-with-class
    'object
    (a-class #f '() '())
    (empty-env)
    )
   )
  )

(define (apply-env env search-var)
  (cases environment env
    (extend-env* (vars vals saved-env)
                 (let ([index (index-of vars search-var)])
                   (if index
                       (list-ref vals index)
                       (apply-env saved-env search-var)
                       )
                   )
                 )
    (extend-env-rec* (p-names b-vars p-bodies saved-env)
                     (let ([index (index-of p-names search-var)])
                       (if index
                           (newref (proc-val (procedure (list (list-ref b-vars index)) (list-ref p-bodies index) env)))
                           (apply-env saved-env search-var)
                           )
                       )
                     )
    (extend-env-with-self-and-super (self super-name saved-env)
                                    (case search-var
                                      ((%self) self)
                                      ((%super) super-name)
                                      (else (apply-env saved-env search-var)))
                                    )
    (else (report-no-binding-found search-var))
    )
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-env "No binding for ~s" var)
  )

(define (lookup-class c-name env)
  (cases environment env
    (extend-env* (vars vals saved-env) (lookup-class c-name saved-env))
    (extend-env-rec* (p-names b-vars p-bodies saved-env) (lookup-class c-name saved-env))
    (extend-env-with-self-and-super (self super-name saved-env) (lookup-class c-name saved-env))
    (extend-env-with-class (class-name c saved-env)
                           (if (eqv? class-name c-name)
                               c
                               (lookup-class c-name saved-env)
                               )
                           )
    (else (report-unknown-class-name c-name))
    )
  )

(define (extend-env-with-class-decl c-decl env)
  (cases class-decl c-decl
    (a-class-decl (c-name s-name f-names m-decls)
                  (extend-env-with-class-components
                   c-name
                   s-name
                   f-names
                   m-decls
                   env
                   )
                  )
    )
  )

(define (extend-env-with-class-components c-name s-name f-names m-decls env)
  (extend-env-with-class
   c-name
   (create-a-class c-name s-name f-names m-decls env)
   env
   )
  )
