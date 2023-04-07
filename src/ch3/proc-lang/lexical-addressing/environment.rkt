#lang eopl

(require "value.rkt")
(require "basic.rkt")
(provide (all-defined-out))

(define (empty-env) '())

; use vec to represent single frame of env
(define (extend-env vals env)
  (let ((vec (list->vector vals)))
    (cons vec env)
    )
  )

(define (extend-env-vec vec env)
  (cons vec env)
  )

(define (init-env)
  (extend-env (list (num-val 1))
              (extend-env (list (num-val 5))
                          (extend-env (list (num-val 10))
                                      (empty-env)
                                      )
                          )
              )
  )

(define (apply-env env search-var)
  (let ((env-offset (car search-var)) (variable-offset (cdr search-var)))
    (let ((target-env (list-ref env env-offset)))
      (if target-env
        (let ((target-var (vector-ref target-env variable-offset)))
          (if target-var
            target-var
            (report-no-binding-found search-var)
          )
        )
        (report-no-binding-found search-var)
        )
      )
    )
  )

(define (environment? env) (list? env))
