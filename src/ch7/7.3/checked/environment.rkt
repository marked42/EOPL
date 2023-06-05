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
   (vars (list-of identifier?))
   (vals (list-of expval?))
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
                (letrec ((loop (lambda (vars vals saved-env)
                                 (if (null? vars)
                                     (apply-env saved-env search-var)
                                     (let ((first-var (car vars)) (first-val (car vals)))
                                       (if (eqv? first-var search-var)
                                           first-val
                                           (loop (cdr vars) (cdr vals) saved-env)
                                           )
                                       )
                                     )
                                 )))
                  (loop vars vals saved-env)
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
