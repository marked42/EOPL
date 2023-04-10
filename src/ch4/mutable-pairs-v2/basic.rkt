#lang eopl

(provide (all-defined-out))

(define identifier? symbol?)

(define (report-expval-extractor-error type val)
  (eopl:error 'expval-extractors "Looking for a ~s, found ~s" type val)
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-env "No binding for ~s" var)
  )
