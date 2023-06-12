#lang eopl

(require racket/lazy-require)
(lazy-require
 ["value.rkt" (num-val expval?)]
 )
(provide (all-defined-out))

(define (empty-nameless-env) '())

(define (extend-namless-env val saved-env)
  (cons val saved-env)
  )

(define (nameless-environment? env) ((list-of expval?) env))

(define (init-nameless-env)
  (extend-namless-env (num-val 1)
                      (extend-namless-env (num-val 5)
                                          (extend-namless-env (num-val 10)
                                                              (empty-nameless-env)
                                                              )
                                          )
                      )
  )

(define (apply-nameless-env env offset)
  (list-ref env offset)
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-nameless-env "No binding for ~s" var)
  )
