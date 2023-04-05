#lang eopl

(require racket/lazy-require "basic.rkt")
(lazy-require
  ["value.rkt" (num-val null-val? cell-val? expval? cell-val->first cell-val->second proc-val)]
  ["expression.rkt" (expression?)]
  ["procedure.rkt" (procedure)]
  ["interpreter.rkt" (value-of-exp)]
)
(provide (all-defined-out))

(define-datatype environment environment?
  (empty-env)
  (extend-env
    (var identifier?)
    (val expval?)
    (env environment?)
  )
  (extend-mul-env
    (vars (list-of identifier?))
    (vals (list-of expval?))
    (env environment?)
  )
  (extend-env-unpack
    (vars (list-of identifier?))
    (val expval?)
    (env environment?)
  )
  (extend-mul-env-let*
    (vars (list-of identifier?))
    ; note exps here is a list of expression? not list of expval?
    (exps (list-of expression?))
    (env environment?)
  )
  (extend-env-rec
    (p-name identifier?)
    (b-name identifier?)
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
    (extend-mul-env (vars vals saved-env)
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
    (extend-env-unpack (vars val saved-env)
      (letrec ((loop (lambda (vars val saved-env)
        (if (null? vars)
          (apply-env saved-env search-var)
          (let ((first-var (car vars)) (first-val (cell-val->first val)))
            (if (eqv? first-var search-var)
              first-val
              (loop (cdr vars) (cell-val->second val) saved-env)
            )
          )
        )
      )))
        (loop vars val saved-env)
      )
    )
    (extend-mul-env-let* (vars exps saved-env)
      (letrec ((loop (lambda (vars exps saved-env)
        (if (null? vars)
          (apply-env saved-env search-var)
          (let ((first-var (car vars)) (first-exp (car exps)))
            (let ((first-val (value-of-exp first-exp saved-env)))
              (if (eqv? first-var search-var)
                first-val
                (loop (cdr vars) (cdr exps)
                  (extend-env first-var first-val saved-env)
                )
              )
            )
          )
        )
      )))
        (loop vars exps saved-env)
      )
    )
    (extend-env-rec (p-name b-name p-body saved-env)
      (if (eqv? search-var p-name)
        ; procedure env is extend-env-rec itself which contains procedure
        ; when procedure is called, procedure body is evaluated in this extend-env-rec
        ; where procedure is visible, which enables recursive call
        (proc-val (procedure (list b-name) p-body env))
        (apply-env saved-env search-var)
      )
    )
    (else (report-no-binding-found search-var))
  )
)

(define (report-unpack-unequal-vars-list-count exp)
  (eopl:error 'unpack-exp "Unequal vars and list count ~s" exp)
  )
