#lang eopl

(require racket/lazy-require "basic.rkt")
(lazy-require
  ["value.rkt" (num-val null-val? cell-val? cell-val->first cell-val->second)]
  ["interpreter.rkt" (value-of-exp)]
)
(provide (all-defined-out))

(define (empty-env) '())

(define (environment? env) (list? env))

; define single var
(define (extend-env var val env)
  (cons (cons var val) env)
  )

; define multiple vars
(define (extend-mul-env vars vals env)
  (if (null? vars)
      env
      (let ((first-var (car vars)) (first-val (car vals)))
        (extend-env
         first-var
         first-val
         (extend-mul-env (cdr vars) (cdr vals) env))
        )
      )
  )

(define (extend-env-unpack vars val env)
  (cond
    ((and (null? vars) (null-val? val)) env)
    ((and (pair? vars) (cell-val? val))
     (let ((first-var (car vars)) (first-val (cell-val->first val)))
       ; define vars from left to right
       (let ((new-env (extend-env first-var first-val env)))
         (extend-env-unpack (cdr vars) (cell-val->second val) new-env)
         )
       )
     )
    (else (report-unpack-unequal-vars-list-count val))
    )
  )

(define (extend-mul-env-let* vars exps env)
  (if (null? vars)
      env
      (let ((first-var (car vars)) (first-exp (car exps)))
        (let ((new-env (extend-env first-var (value-of-exp first-exp env) env)))
          ; let* evalutates with previous defined variable visible to following initialization expression
          (extend-mul-env-let* (cdr vars) (cdr exps) new-env))
        )
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
  (if (null? env)
      (report-no-binding-found search-var)
      (let ((saved-var (caar env)) (saved-val (cdar env)) (saved-env (cdr env)))
        (if (eqv? saved-var search-var)
            saved-val
            (apply-env saved-env search-var)
            )
        )
      )
  )

(define (report-unpack-unequal-vars-list-count exp)
  (eopl:error 'unpack-exp "Unequal vars and list count ~s" exp)
  )
