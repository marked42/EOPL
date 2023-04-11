#lang eopl

(provide (all-defined-out))

(define (empty-store) '())

(define the-store 'uninitialized)

(define (get-store) the-store)

(define (initialize-store!)
  (set! the-store (empty-store))
  )

(define (vals->refs vals)
  (map (lambda (val)
         (if (reference? val)
             val
             (newref val)
             )
         ) vals)
  )

(define (reference? v) (integer? v))

(define (show-store)
  (display "store is: ")
  (newline)
  (eopl:pretty-print the-store)
  )

(define (newref val)
  (let ((next-ref (length the-store)))
    (set! the-store (append the-store (list val)))
    next-ref
    )
  )

(define (deref ref)
  (list-ref the-store ref)
  )

(define (setref ref val)
  (letrec ((loop (lambda (store ref)
                   (cond
                     ((null? store) (report-invalid-reference ref the-store))
                     ((zero? ref) (cons val (cdr store)))
                     (else (cons (car store) (loop (cdr store) (- ref 1))))
                     )
                   )))
    (set! the-store (loop the-store ref))
    )
  )

(define report-invalid-reference
  (lambda (ref the-store)
    (eopl:error 'setref
                "illegal reference ~s in store ~s"
                ref the-store)))
