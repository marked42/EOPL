#lang eopl

(provide (all-defined-out))

(define (proc? val) (procedure? val))

(define (apply-procedure proc arg)
  (proc arg)
  )
