#lang eopl

(require racket/lazy-require racket/list "expression.rkt")
(lazy-require
 ["value.rkt" (num-val expval? proc-val)]
 ["store.rkt" (reference? newref)]
 ["procedure.rkt" (procedure)]
 )
(provide (all-defined-out))

(define-datatype environment environment?
  (empty-env)
  (extend-env
   (var symbol?)
   (val (lambda (val) (or (reference? val) (expval? val))))
   (saved-env environment?)
   )
  (extend-env-rec*
   (p-names (list-of symbol?))
   (b-vars (list-of symbol?))
   (p-bodies (list-of expression?))
   (saved-env environment?)
   )
  )

(define (init-env)
  ; immutable variables
  (extend-env 'i (num-val 1)
              (extend-env 'v (num-val 5)
                          (extend-env 'x (num-val 10)
                                      (empty-env)
                                      )
                          )
              )
  )

(define (apply-env env search-var)
  (cases environment env
    (extend-env (var val saved-env)
                (if (eqv? search-var var)
                    val
                    (apply-env saved-env search-var)
                    )
                )
    (extend-env-rec* (p-names b-vars p-bodies saved-env)
                     (let ([index (index-of p-names search-var)])
                       (if index
                           ; new stuff
                           (proc-val (procedure (list-ref b-vars index) (list-ref p-bodies index) env))
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
