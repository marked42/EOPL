#lang eopl

(provide (all-defined-out))

(define (maybe pred)
  (lambda (v) (or (not v) (pred v)))
  )
