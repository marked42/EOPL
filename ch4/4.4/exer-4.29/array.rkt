#lang eopl

(require racket/lazy-require)
(lazy-require
 ["store.rkt" (reference? next-ref newref deref setref! show-store)]
 ["value.rkt" (num-val)]
 )

(provide (all-defined-out))

(define-datatype array array?
  (an-array (start reference?) (len integer?))
  )

(define (new-array len val)
    (let ([start (next-ref)])
        (let loop ([i 0])
            (if (< i len)
                (begin
                    (newref val)
                    (loop (+ i 1))
                )
                #f
            )
        )
        (an-array start len)
    )
)

(define (check-array-index len index)
    (cond
        [(< index 0) (eopl:error 'check-array-index "array index cannot be smaller than first element index 0, get ~s" index)]
        [(>= index len) (eopl:error 'check-array-index "array index cannot be greater than last element index ~s, get ~s" (- len 1) index)]
        [else #t]
    )
)

(define (array-ref arr index)
    (cases array arr
        (an-array (start len)
            (check-array-index len index)
            (deref (+ start index))
        )
    )
)

(define (array-set! arr index val)
    (cases array arr
        (an-array (start len)
            (check-array-index len index)
            (setref! (+ start index) val)
            val
        )
    )
)
