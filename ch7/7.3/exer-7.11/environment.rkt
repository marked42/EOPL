#lang eopl

(require racket/lazy-require "expression.rkt")
(lazy-require
 ["value.rkt" (num-val expval? proc-val)]
 ["procedure.rkt" (procedure)]
 ["store.rkt" (reference? newref)]
 )
(provide (all-defined-out))

(define-datatype environment environment?
  (empty-env)
  (extend-env
   (var symbol?)
   (val reference?)
   (saved-env environment?)
   )
  (extend-env-rec
   (p-name symbol?)
   (b-var symbol?)
   (p-body expression?)
   (saved-env environment?)
   )
  )

(define (init-env)
  (extend-env 'i (newref (num-val 1))
              (extend-env 'v (newref (num-val 5))
                          (extend-env 'x (newref (num-val 10))
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
                        (newref (proc-val (procedure b-var p-body env)))
                        (apply-env saved-env search-var)
                        )
                    )
    (else (report-no-binding-found search-var))
    )
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-env "No binding for ~s" var)
  )
