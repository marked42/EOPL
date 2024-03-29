#lang eopl

(require racket/lazy-require)
(lazy-require
 ["value.rkt" (num-val expval?)]
 )
(provide (all-defined-out))

(define (empty-nameless-env) '())

(define (extend-nameless-env vals saved-env)
  (cons vals saved-env)
  )

(define (nameless-environment? env) ((list-of (list-of expval?)) env))

(define (init-nameless-env)
  (extend-nameless-env (list (num-val 1))
                       (extend-nameless-env (list (num-val 5))
                                            (extend-nameless-env (list (num-val 10))
                                                                 (empty-nameless-env)
                                                                 )
                                            )
                       )
  )

(define (apply-nameless-env env depth position)
  (list-ref (list-ref env depth) position)
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-nameless-env "No binding for ~s" var)
  )
