#lang eopl

(require racket/lazy-require racket/list "expression.rkt")
(lazy-require
 ["value.rkt" (num-val expval? proc-val)]
 ["procedure.rkt" (procedure)]
 )
(provide (all-defined-out))

(define-datatype environment environment?
  (empty-env)
  (extend-env*
   (vars (list-of symbol?))
   (vals (list-of expval?))
   (saved-env environment?)
   )
  (extend-env-rec*
   (p-names (list-of symbol?))
   (b-vars-list (list-of (list-of symbol?)))
   (p-bodies (list-of expression?))
   (saved-env environment?)
   )
  )

(define (init-env)
  (extend-env*
   (list 'i 'v 'x)
   (list (num-val 1) (num-val 5) (num-val 10))
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
    (extend-env-rec* (p-names b-vars-list p-bodies saved-env)
                     (let ([index (index-of p-names search-var)])
                       (if index
                           ; procedure env is extend-env-rec itself which contains procedure
                           ; when procedure is called, procedure body is evaluated in this extend-env-rec
                           ; where procedure is visible, which enables recursive call
                           (proc-val (procedure (list-ref b-vars-list index) (list-ref p-bodies index) env))
                           (apply-env saved-env search-var)
                           )
                       )
                     )
    (else (report-no-binding-found search-var))
    )
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-env "No binding for ~s" var)
  )
