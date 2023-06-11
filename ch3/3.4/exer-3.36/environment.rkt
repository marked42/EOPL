#lang eopl

(require racket/lazy-require "expression.rkt")
(lazy-require
 ["value.rkt" (num-val expval? proc-val)]
 ["procedure.rkt" (procedure)]
 )
(provide (all-defined-out))

(define environment? procedure?)

(define (empty-env)
  (lambda (search-var)
    (report-no-binding-found search-var)
  )
)

(define (extend-env var val saved-env)
  (lambda (search-var)
          (if (eqv? search-var var)
              val
              (apply-env saved-env search-var)
              )
  )
)

; new stuff
(define (extend-env-rec p-names b-vars p-bodies saved-env)
  (let loop ([p-names p-names] [b-vars b-vars] [p-bodies p-bodies] [saved-env saved-env])
    (if (null? p-names)
      saved-env
      (let ([vec (make-vector 1)])
        (let ([new-env (extend-env (car p-names) vec saved-env)])
          (vector-set! vec 0 (proc-val (procedure (car b-vars) (car p-bodies) new-env)))
          (loop (cdr p-names) (cdr b-vars) (cdr p-bodies) new-env)
        )
      )
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
  (let ([val (env search-var)])
    (if (vector? val)
      ; if val is vector, it contains a proc-val
      (vector-ref val 0)
      val
      )
    )
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-env "No binding for ~s" var)
  )
