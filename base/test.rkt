#lang eopl

(require racket/list rackunit)

(provide (all-defined-out))

(define (test-lang run sloppy->expval test-cases)
  (let ([equal-answer? (lambda (ans correct-ans msg) (check-equal? ans (sloppy->expval correct-ans) msg))])
    (map (lambda (test-case)
           (let ([source (first test-case)] [expected (second test-case)] [msg (third test-case)])
             (equal-answer? (run source) expected msg)
             )
           ) test-cases)
    )
  )

(define test-cases-const-exp
  (list
   (list "1" 1 "const-exp")
   )
  )

(define test-cases-diff-exp
  (list
   (list "-(1, 2)" -1 "diff-exp")
   )
  )

(define test-cases-zero?-exp
  (list
   (list "zero?(0)" #t "zero?-exp")
   (list "zero?(1)" #f "zero?-exp")
   )
  )

(define test-cases-if-exp
  (list
   (list "if zero? (0) then 2 else 3" 2 "if exp")
   (list "if zero? (1) then 2 else 3" 3 "if exp")
   )
  )

(define test-cases-var-exp
  (list
   (list "i" 1 "built in var i is 1")
   (list "v" 5 "built in var i is 5")
   (list "x" 10 "built in var i is 10")
   )
  )

(define test-cases-let-exp
  (list
   (list "let a = 1 in -(a, x)" -9 "let exp")
   )
  )

(define test-cases-let-lang
  (append
   test-cases-const-exp
   test-cases-diff-exp
   test-cases-zero?-exp
   test-cases-var-exp
   test-cases-if-exp
   test-cases-let-exp
   )
  )

(define test-cases-proc-exp
  (list
   (list "let f = proc (x) -(x,11) in (f (f 77))" 55 "proc-exp")
   (list "(proc (f) (f (f 77)) proc (x) -(x,11))" 55 "proc-exp")
   )
  )

(define test-cases-proc-lang
  (append
   test-cases-let-lang
   test-cases-proc-exp
   )
  )

(define test-cases-letrec-exp
  (list
   (list "
letrec double(x)
  = if zero?(x) then 0 else -((double -(x,1)), -2)
    in (double 6)
" 12 "letrec-exp")
   )
  )

(define test-cases-letrec-lang
  (append
   test-cases-proc-lang
   test-cases-letrec-exp
   )
  )

(define test-cases-minus-exp
  (list
   (list "minus(-(minus(5), 9))" 14 "minus-exp")
   )
  )
