#lang eopl

(provide (all-defined-out))

(define (merge loi1 loi2)
  (cond ((null? loi1) loi2)
        ((null? loi2) loi1)
        (else
         (let ((f1 (car loi1))
               (r1 (cdr loi1))
               (f2 (car loi2))
               (r2 (cdr loi2)))
           (if (< f1 f2)
               (cons f1 (merge r1 loi2))
               (cons f2 (merge loi1 r2))
               )
           ))
        )
  )
