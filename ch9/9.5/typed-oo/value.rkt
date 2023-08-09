#lang eopl

(require racket/lazy-require "expression.rkt")
(lazy-require
 ["procedure.rkt" (proc?)]
 ["object.rkt" (object?)]
 )

(provide (all-defined-out))

(define (report-expval-extractor-error type val)
  (eopl:error 'expval-extractors "Looking for a ~s, found ~s" type val)
  )

(define-datatype expval expval?
  (num-val (num number?))
  (bool-val (bool boolean?))
  (proc-val (proc1 proc?))
  (null-val)
  (cell-val (first (or-pred expval? object?)) (second (or-pred expval? object?)))
  )

(define (or-pred pred1 pred2)
  (lambda (val) (or (pred1 val) (pred2 val)))
)

(define (expval->num val)
  (cases expval val
    (num-val (num) num)
    (else (report-expval-extractor-error 'num val))
    )
  )

(define (expval->bool val)
  (cases expval val
    (bool-val (bool) bool)
    (else (report-expval-extractor-error 'bool val))
    )
  )

(define (expval->proc val)
  (cases expval val
    (proc-val (proc1) proc1)
    (else (report-expval-extractor-error 'proc val))
    )
  )

; new stuff
(define (cell-val->first val)
  (cases expval val
    (cell-val (first second) first)
    (null-val () (null-val))
    (else (eopl:error 'cell-val->first "val must be a cell, get ~s" val))
    )
  )

(define (cell-val->second val)
  (cases expval val
    (cell-val (first second) second)
    (null-val () (null-val))
    (else (eopl:error 'cell-val->second "val must be a cell, get ~s" val))
    )
  )

(define (null-val? val)
  (cases expval val
    (null-val () #t)
    (else #f)
    )
  )

(define (cell-val? val)
  (cases expval val
    (cell-val (first second) #t)
    (else #f)
    )
  )

(define sloppy->expval
  (lambda (sloppy-val)
    (cond
      ((number? sloppy-val) (num-val sloppy-val))
      ((boolean? sloppy-val) (bool-val sloppy-val))
      ; new stuff
      ((null? sloppy-val) (null-val))
      ((pair? sloppy-val)
       (let ((first (car sloppy-val)) (second (cdr sloppy-val)))
         (cell-val (sloppy->expval first) (sloppy->expval second))
         )
       )
      (else
       (eopl:error 'sloppy->expval
                   "Can't convert sloppy value to expval: ~s"
                   sloppy-val)))))
