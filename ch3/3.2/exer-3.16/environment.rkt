#lang eopl

(require racket/lazy-require racket/list)
(lazy-require
 ["value.rkt" (num-val expval?)]
 )
(provide (all-defined-out))

(define-datatype environment environment?
  (empty-env)
  (extend-env*
   (vars (list-of symbol?))
   (vals (list-of expval?))
   (saved-env environment?)
   )
  )

(define (init-env)
  (extend-env*
    (list 'i 'v 'x)
    (list (num-val 1) (num-val 5) (num-val 10))
    (empty-env)
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
    (else (report-no-binding-found search-var))
    )
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-env "No binding for ~s" var)
  )
