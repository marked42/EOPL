#lang eopl

(require racket/lazy-require "expression.rkt" "module.rkt")
(lazy-require
 [racket (mcons mcdr)]
 ["value.rkt" (num-val expval? proc-val module-val expval->module)]
 ["procedure.rkt" (procedure)]
 )
(provide (all-defined-out))

(define-datatype environment environment?
  (empty-env)
  (extend-env
   (var symbol?)
   (val expval?)
   (saved-env environment?)
   )
  (extend-env-rec
   (p-name symbol?)
   (b-var symbol?)
   (p-body expression?)
   (saved-env environment?)
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

(define (lookup-qualified-var-in-env m-name var-name env)
  (let* ([val (apply-env env m-name)] [mod (expval->module val)] [mod-val (mcdr mod)])
    (if (eqv? mod-val 'uninitialized)
      (eopl:error 'lookup-qualified-var-in-env "Module ~s is not imported yet." m-name)
      (cases typed-module mod-val
        (simple-module (bindings)
                      (apply-env bindings var-name)
                      )
        )
      )
    )
  )

(define (extend-env-with-module m-name m-body saved-env)
  (extend-env m-name (module-val (mcons m-body 'uninitialized)) saved-env)
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-env "No binding for ~s" var)
  )
