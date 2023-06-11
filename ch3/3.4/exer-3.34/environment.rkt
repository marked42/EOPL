#lang eopl

(require racket/lazy-require "expression.rkt")
(lazy-require
 ["value.rkt" (num-val expval? proc-val)]
 ["procedure.rkt" (procedure)]
 )
(provide (all-defined-out))

(define environment? procedure?)

(define (empty-env)
  (lambda (search-var)
    (report-no-binding-found search-var)
  )
)

(define (extend-env var val saved-env)
  (lambda (search-var)
          (if (eqv? search-var var)
              val
              (apply-env saved-env search-var)
              )
  )
)

(define (extend-env-rec p-name b-var p-body saved-env)
  (letrec ([new-env (lambda (search-var)
          (if (eqv? search-var p-name)
              ; use letrec to use new-env inside new-new
              (proc-val (procedure b-var p-body new-env))
              (apply-env saved-env search-var)
              ))])
      new-env
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
  (env search-var)
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-env "No binding for ~s" var)
  )
