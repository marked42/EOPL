#lang eopl

(require racket/lazy-require racket/list "expression.rkt")
(lazy-require
 ["value.rkt" (num-val expval? proc-val)]
 ["store.rkt" (reference? newref)]
 ["procedure.rkt" (procedure)]
 ["object.rkt" (object?)]
 ["checker/type.rkt" (type? int-type void-type)]
 )
(provide (all-defined-out))

(define-datatype environment environment?
  (empty-env)
  (extend-env*
   (vars (list-of symbol?))
   (vals (list-of reference?))
   (types (list-of type?))
   (saved-env environment?)
   )
  (extend-env-rec*
   (p-names (list-of symbol?))
   (b-vars-list (list-of (list-of symbol?)))
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
   (list (int-type) (int-type) (int-type))
   (empty-env)
   )
  )

(define (apply-env env search-var)
  (cases environment env
    (extend-env* (vars vals types saved-env)
                 (let ([index (index-of vars search-var)])
                   (if index
                       (list-ref vals index)
                       (apply-env saved-env search-var)
                       )
                   )
                 )
    (extend-env-rec* (p-names b-vars-list p-bodies saved-env)
                     (let ([index (index-of p-names search-var)])
                       (if index
                           ; use void type as stub type for procedure of letrec, never used
                           (newref (proc-val (procedure (list-ref b-vars-list index) (map (lambda (name) (void-type)) p-names) (list-ref p-bodies index) env)))
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

(define (find-var-type env search-var)
  (cases environment env
    (extend-env* (vars vals types saved-env)
                 (let ([index (index-of vars search-var)])
                   (if index
                       (list-ref types index)
                       (apply-env saved-env search-var)
                       )
                   )
                 )
    (extend-env-rec* (p-names b-vars-list p-bodies saved-env)
                     (apply-env saved-env search-var)
                     )
    (extend-env-with-self-and-super (self super-name saved-env)
                                    (apply-env saved-env search-var)
                                    )
    (else (report-no-binding-found search-var))
    )
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-env "No binding for ~s" var)
  )
