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
  (null-val)
  (cell-val
   (first expval?)
   (second expval?)
   )
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

(define (cell-val->first val)
  (cases expval val
    (cell-val (first second) first)
    (null-val () (null-val))
    (else "error")
    )
  )

(define (cell-val->second val)
  (cases expval val
    (cell-val (first second) second)
    (null-val () (null-val))
    (else "error")
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


(define (equal-answer? ans correct-ans msg)
  (check-equal? ans (sloppy->expval correct-ans) msg)
  )

(define (sloppy->expval sloppy-val)
  (cond
    ((number? sloppy-val) (num-val sloppy-val))
    ((boolean? sloppy-val) (bool-val sloppy-val))
    ((null? sloppy-val) (null-val))
    ((pair? sloppy-val)
      (let ((first (car sloppy-val)) (second (cdr sloppy-val)))
        (cell-val (sloppy->expval first) (sloppy->expval second))
        )
      )
    (else
     (eopl:error 'sloppy->expval
                 "Can't convert sloppy value to expval: ~s"
                 sloppy-val))))

(define (report-expval-extractor-error type val)
  (eopl:error 'expval-extractors "Looking for a ~s, found ~s" type val)
  )
