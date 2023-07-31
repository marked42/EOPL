#lang eopl

(require racket/lazy-require racket/list "expression.rkt")
(lazy-require
 ["value.rkt" (num-val expval? proc-val)]
 ["store.rkt" (reference? newref)]
 ["procedure.rkt" (procedure)]
 ["object.rkt" (object?)]
 )
(provide (all-defined-out))

(define-datatype environment environment?
  (empty-env)
  (extend-env-proc*
   (vars (list-of symbol?))
   (vals (list-of reference?))
   (saved-env environment?)
   )
  (extend-env-method*
   (class-name symbol?)
   (method-name symbol?)
   (vars (list-of symbol?))
   (vals (list-of reference?))
   (saved-env environment?)
   )
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
   (empty-env)
   )
  )

(define (apply-extend-env* search-var vars vals saved-env)
  (let ([index (index-of vars search-var)])
    (if index
        (list-ref vals index)
        (apply-env saved-env search-var)
        )
    )
  )

(define (apply-env env search-var)
  (cases environment env
    (extend-env* (vars vals saved-env) (apply-extend-env* search-var vars vals saved-env))
    (extend-env-proc* (vars vals saved-env) (apply-extend-env* search-var vars vals saved-env))
    (extend-env-method* (class-name method-name vars vals saved-env) (apply-extend-env* search-var vars vals saved-env))
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

(define (find-caller-class-method env)
  (cases environment env
    (extend-env* (vars vals saved-env) (find-caller-class-method saved-env))
    (extend-env-proc* (vars vals saved-env) #f)
    (extend-env-method* (class-name method-name vars vals saved-env) (cons class-name method-name))
    (extend-env-rec* (p-names b-vars p-bodies saved-env) #f)
    (extend-env-with-self-and-super (self super-name saved-env)
                                    (find-caller-class-method saved-env)
                                    )
    (else #f)
    )
  )
