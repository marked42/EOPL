#lang eopl

(require racket/lazy-require racket/list "basic.rkt")
(lazy-require
 ["value.rkt" (num-val  expval? proc-val)]
 ["expression.rkt" (expression?)]
 ["procedure.rkt" (procedure)]
 )
(provide (all-defined-out))

(define-datatype environment environment?
  (empty-env)
  (extend-env
   (vars (list-of identifier?))
   (vals (list-of expval?))
   (env environment?)
   )
  (extend-env-rec
   (p-name (list-of identifier?))
   (b-vars (list-of (list-of identifier?)))
   (p-body (list-of expression?))
   (env environment?)
   )
  )

(define (init-env)
  (extend-env (list 'i) (list (num-val 1))
              (extend-env (list 'v) (list (num-val 5))
                          (extend-env (list 'x) (list (num-val 10))
                                      (empty-env)
                                      )
                          )
              )
  )

(define (apply-env env search-var)
  (cases environment env
    (extend-env (vars vals saved-env)
                (let ((index (index-of vars search-var)))
                  (if index
                    (list-ref vals index)
                    (apply-env saved-env search-var)
                    )
                  )
                )
    (extend-env-rec (p-names b-vars-list p-bodies saved-env)
                    (let ((index (index-of p-names search-var)))
                      (if index
                        (let ((b-vars (list-ref b-vars-list index))
                              (p-body (list-ref p-bodies index)))
                          (proc-val (procedure b-vars p-body env))
                        )
                        (apply-env saved-env search-var)
                        )
                      )
                    )
    (else (report-no-binding-found search-var))
    )
  )
