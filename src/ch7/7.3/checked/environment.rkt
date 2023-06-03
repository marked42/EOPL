#lang eopl

(require racket/lazy-require "basic.rkt")
(lazy-require
 ["value.rkt" (num-val  expval? proc-val)]
 ["expression.rkt" (expression?)]
 ["procedure.rkt" (procedure)]
 )
(provide (all-defined-out))

(define-datatype environment environment?
  (empty-env)
  (extend-env
   (var identifier?)
   (val expval?)
   (env environment?)
   )
  (extend-env-rec
   (p-name identifier?)
   (b-var identifier?)
   (p-body expression?)
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
    (extend-env-rec (p-name b-var p-body saved-env)
                    (if (eqv? search-var p-name)
                        ; procedure env is extend-env-rec itself which contains procedure
                        ; when procedure is called, procedure body is evaluated in this extend-env-rec
                        ; where procedure is visible, which enables recursive call
                        (proc-val (procedure b-var p-body env))
                        (apply-env saved-env search-var)
                        )
                    )
    (else (report-no-binding-found search-var))
    )
  )
