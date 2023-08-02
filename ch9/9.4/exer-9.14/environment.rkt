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
   (host-name symbol?)
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
    (extend-env-with-self-and-super (self host-name super-name saved-env)
                                    (case search-var
                                      ((%self) self)
                                      ((%host) host-name)
                                      ((%super) super-name)
                                      (else (apply-env saved-env search-var)))
                                    )
    (else (report-no-binding-found search-var))
    )
  )

(define (has-var-env env search-var)
  (cases environment env
    (extend-env* (vars vals saved-env)
                 (let ([index (index-of vars search-var)])
                   (if index
                       #t
                       (has-var-env saved-env search-var)
                       )
                   )
                 )
    (extend-env-rec* (p-names b-vars p-bodies saved-env)
                     (let ([index (index-of p-names search-var)])
                       (if index
                           #t
                           (has-var-env saved-env search-var)
                           )
                       )
                     )
    (extend-env-with-self-and-super (self host-name super-name saved-env)
                                    (case search-var
                                      ((%self) self)
                                      ((%host) host-name)
                                      ((%super) super-name)
                                      (else (has-var-env saved-env search-var)))
                                    )
    (else #f)
    )
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-env "No binding for ~s" var)
  )
