#lang eopl

(require racket/lazy-require)
(lazy-require
 [rackunit (check-equal?)]
 ["procedure.rkt" (proc?)]
 )

(provide (all-defined-out))

(define-datatype expval expval?
  (num-val
   (num number?)
   )
  (bool-val
   (bool boolean?)
   )
  (proc-val (proc1 proc?))
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


(define (equal-answer? ans correct-ans msg)
  (check-equal? ans (sloppy->expval correct-ans) msg)
  )

(define (sloppy->expval sloppy-val)
  (cond
    ((number? sloppy-val) (num-val sloppy-val))
    ((boolean? sloppy-val) (bool-val sloppy-val))
    (else
     (eopl:error 'sloppy->expval
                 "Can't convert sloppy value to expval: ~s"
                 sloppy-val))))

(define (report-expval-extractor-error type val)
  (eopl:error 'expval-extractors "Looking for a ~s, found ~s" type val)
  )
