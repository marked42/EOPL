#lang eopl

(require racket/lazy-require)
(lazy-require
 ["value.rkt" (num-val)]
 ["store.rkt" (newref reference?)]
 ["var-index.rkt" (var-index->depth var-index->offset)]
 )
(provide (all-defined-out))

(define (empty-nameless-env) '())

(define (extend-nameless-env vals saved-env)
  (cons vals saved-env)
  )

(define (nameless-environment? env) ((list-of (list-of reference?)) env))

(define (init-nameless-env)
  (extend-nameless-env (list (newref (num-val 1)))
                       (extend-nameless-env (list (newref (num-val 5)))
                                            (extend-nameless-env (list (newref (num-val 10)))
                                                                 (empty-nameless-env)
                                                                 )
                                            )
                       )
  )

(define (apply-nameless-env env index)
  (let* ([depth (var-index->depth index)] [offset (var-index->offset index)])
    (list-ref (list-ref env depth) offset)
    )
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-nameless-env "No binding for ~s" var)
  )
