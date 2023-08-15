#lang eopl

(provide (all-defined-out))

(define-datatype var-index var-index?
  (a-var-index
   (depth integer?)
   (offset integer?)
   )
  )

(define (var-index->depth index)
  (cases var-index index
    (a-var-index (depth offset) depth)
    )
  )

(define (var-index->offset index)
  (cases var-index index
    (a-var-index (depth offset) offset)
    )
  )
