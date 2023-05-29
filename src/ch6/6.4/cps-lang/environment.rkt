#lang eopl

(require racket/lazy-require racket/list)
(lazy-require
 ["../../../base/basic.rkt" (identifier? report-no-binding-found)]
 ["value.rkt" (num-val proc-val expval?)]
 ["procedure.rkt" (create-procedure)]
 ["expression.rkt" (tfexp?)]
 )
(provide (all-defined-out))

(define-datatype environment environment?
  (empty-env)
  (extend-env
   (var identifier?)
   (val expval?)
   (env environment?)
   )
  (extend-env*
   (vars (list-of identifier?))
   (vals (list-of expval?))
   (env environment?)
   )
  (extend-env-rec*
   (p-names (list-of identifier?))
   (b-varss (list-of (list-of identifier?)))
   (p-bodies (list-of tfexp?))
   (env environment?)
   )
  )

(define (init-env)
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
    (extend-env* (vars vals saved-env)
                 (let ((index (index-of vars search-var)))
                   (if index
                       (list-ref vals index)
                       (apply-env saved-env search-var)
                       )
                   )
                 )
    (extend-env-rec* (p-names b-varss p-bodies saved-env)
                     (let ((index (index-of p-names search-var)))
                       (if index
                           ; use env as its parent env for recursive definition
                           (proc-val (create-procedure (list-ref b-varss index) (list-ref p-bodies index) env))
                           (apply-env saved-env search-var)
                           )
                       )
                     )
    (else (report-no-binding-found search-var))
    )
  )
