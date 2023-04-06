#lang eopl

(require racket/lazy-require "basic.rkt")
(lazy-require
 ["value.rkt" (num-val null-val? cell-val? expval? cell-val->first cell-val->second proc-val)]
 ["expression.rkt" (expression?)]
 ["procedure.rkt" (procedure)]
 ["interpreter.rkt" (value-of-exp)]
 )
(provide (all-defined-out))

(define environment? procedure?)

(define (extend-env var val env)
  (lambda (search-var)
    (if (eqv? search-var var)
        val
        (apply-env env search-var)
        )
    )
  )

(define (apply-env env search-var)
  (env search-var)
  )

(define (empty-env)
  (lambda (search-var)
    (report-no-binding-found search-var)
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

(define (extend-mul-env vars vals saved-env)
  (lambda (search-var)
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
  )

(define (extend-mul-env-let* vars exps saved-env)
  (lambda (search-var)
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
    ))

(define (extend-env-unpack vars val saved-env)
  (lambda (search-var)
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
    ))

; use a vec to build circular refs to avoid create same proc-val multiple times
(define (build-circular-extend-env-rec-mul-vec p-names b-vars-list p-bodies saved-env)
  ; a direct mutual reference between proc-val and new-env cannot be created
  ; so we use vec to build a indirect mutual references
  (let ((vec (make-vector (length p-names))))
    ; new-env -> vec
    (let ((new-env (extend-env-rec-mul-vec p-names vec saved-env)))
      (letrec ((loop (lambda (p-names b-vars-list p-bodies i)
                       (if (null? p-names)
                           '()
                           (let ((first-b-vars (car b-vars-list)) (first-p-body (car p-bodies)))
                             ; vec -> proc-val -> new-env
                             (vector-set! vec i (proc-val (procedure first-b-vars first-p-body new-env)))
                             (loop (cdr p-names) (cdr b-vars-list) (cdr p-bodies) (+ i 1))
                             )
                           )
                       )))
        (loop p-names b-vars-list p-bodies 0)
        ; return this directly without wrapping a in another lambda
        new-env
        )
      )
    )
  )

(define (extend-env-rec-mul-vec p-names vec saved-env)
  (lambda (search-var)
    (letrec ((loop (lambda (p-names i)
                     (if (null? p-names)
                         (apply-env saved-env search-var)
                         (let ((first-p-name (car p-names)))
                           (if (eqv? first-p-name search-var)
                               (vector-ref vec i)
                               (loop (cdr p-names) (+ i 1))
                               )
                           )
                         )
                     )))
      (loop p-names 0)
      )
    ))
