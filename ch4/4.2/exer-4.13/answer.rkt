#lang eopl

(require racket/lazy-require)
(lazy-require
 ["value.rkt" (expval?)]
 ["store.rkt" (store?)]
 )

(provide (all-defined-out))

(define-datatype answer answer?
  (an-answer (val expval?) (store store?))
  )
