#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../transformer-book/test-transformer.rkt" (
                                              test-transform-exp
                                              test-transform-const-exp
                                              test-transform-var-exp
                                              test-transform-diff-exp
                                              test-transform-zero?-exp
                                              test-transform-call-exp
                                              test-transform-sum-exp
                                              test-transform-proc-exp
                                              test-transform-let-exp
                                              test-transform-letrec-exp
                                              )]
 )

(provide (all-defined-out))

(define (test-transformer transform)
  (test-transform-const-exp transform)
  (test-transform-var-exp transform)
  (test-transform-diff-exp transform)
  (test-transform-zero?-exp transform)
  (test-transform-call-exp transform)
  (test-transform-sum-exp transform)
  (test-transform-if-exp transform)
  (test-transform-proc-exp transform)
  (test-transform-let-exp transform)
  (test-transform-letrec-exp transform)
  )

(define (test-transform-if-exp transform)
  (test-transform-exp transform "if zero?(0) then 2 else 3" "let k%01 = proc (var%1) var%1 in if zero?(0) then (k%01 2) else (k%01 3)" "if-exp")
  (test-transform-exp transform "if (a 1) then (p x) else (p y)" "(a 1 proc (var%2) let k%01 = proc (var%1) var%1 in if var%2 then (p x k%01) else (p y k%01))" "if-exp")
  (test-transform-exp transform "if 0 then if 1 then (p x1) else (p y1) else if 2 then (p x2) else (p y2)" "let k%01 = proc (var%1) var%1 in if 0 then if 1 then (p x1 k%01) else (p y1 k%01) else if 2 then (p x2 k%01) else (p y2 k%01)" "if-exp")
  )
