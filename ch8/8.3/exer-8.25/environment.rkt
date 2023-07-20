#lang eopl

(require racket/lazy-require racket/list "expression.rkt" "module.rkt")
(lazy-require
 ["value.rkt" (num-val expval? proc-val)]
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
  (extend-env-with-module
   (m-names (list-of symbol?))
   (m-vals (list-of typed-module?))
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
  (let ([m-val (lookup-module-name-in-env m-name env)])
    (cases typed-module m-val
      (simple-module (bindings)
                     (apply-env bindings var-name)
                     )
      (proc-module (eopl:error 'lookup-qualified-var-in-env "fail to find module ~s" m-name))
      )
    )
  )

(define (lookup-module-name-in-env m-name env)
  (cases environment env
    (extend-env (var val saved-env)
                (lookup-module-name-in-env m-name saved-env)
                )
    (extend-env-rec (p-name b-var p-body saved-env)
                    (lookup-module-name-in-env m-name saved-env)
                    )
    (extend-env-with-module (m-names m-vals saved-env)
                            (let ([index (index-of m-names m-name)])
                              (if index
                                  (list-ref m-vals index)
                                  (lookup-module-name-in-env m-name saved-env)
                                  )
                              )
                            )
    (else (eopl:error 'lookup-module-name-in-env "fail to find module name ~s" m-name))
    )
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-env "No binding for ~s" var)
  )
