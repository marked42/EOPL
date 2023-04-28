#lang eopl

(require racket/lazy-require)
(lazy-require
 ["basic.rkt" (identifier?)]
 ["expression.rkt" (expression?)]
 ["environment.rkt" (environment?)]
 ["value.rkt" (expval?)]
 )

(provide (all-defined-out))

(define-datatype continuation cont?
  (end-cont)
  (diff-cont (saved-cont cont?) (exp2 expression?) (saved-env environment?))
  (diff-cont-1 (saved-cont cont?) (val1 expval?))
  (zero?-cont (saved-cont cont?))
  (if-cont (saved-cont cont?) (exp2 expression?) (exp3 expression?) (saved-env environment?))
  (let-cont (saved-cont cont?) (var identifier?) (body expression?) (env environment?))
  (call-cont (saved-cont cont?) (rands expression?) (saved-env environment?))
  (call-cont-1 (saved-cont cont?) (rator expval?))
  )
