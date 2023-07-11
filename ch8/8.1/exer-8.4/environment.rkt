#lang eopl

(require racket/lazy-require racket/list "expression.rkt" "module.rkt")
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
  (extend-env-rec
   (p-name symbol?)
   (b-var symbol?)
   (p-body expression?)
   (saved-env environment?)
   )
  (extend-env-with-module
   (m-name symbol?)
   (m-val typed-module?)
   (saved-env environment?)
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
    (extend-env-rec (p-name b-var p-body saved-env)
                    (if (eqv? search-var p-name)
                        ; procedure env is extend-env-rec itself which contains procedure
                        ; when procedure is called, procedure body is evaluated in this extend-env-rec
                        ; where procedure is visible, which enables recursive call
                        (proc-val (procedure (list b-var) p-body env))
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
      )
    )
  )

(define (lookup-module-name-in-env m-name env)
  (cases environment env
    (extend-env* (vars vals saved-env)
                 (lookup-module-name-in-env m-name saved-env)
                 )
    (extend-env-rec (p-name b-var p-body saved-env)
                    (lookup-module-name-in-env m-name saved-env)
                    )
    (extend-env-with-module (this-m-name m-val saved-env)
                            (if (equal? m-name this-m-name)
                                m-val
                                (lookup-module-name-in-env m-name saved-env)
                                )
                            )
    (else (eopl:error 'lookup-module-name-in-env "fail to find module name ~s" m-name))
    )
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-env "No binding for ~s" var)
  )
