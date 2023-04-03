#lang eopl

(require rackunit)
(require "interpreter.rkt")
(require "value.rkt")

(define equal-answer?
  (lambda (ans correct-ans msg)
    (check-equal? ans (sloppy->expval correct-ans) msg)))

(define sloppy->expval
  (lambda (sloppy-val)
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
                   sloppy-val)))))

(equal-answer? (run "1") 1 "const exp")
(equal-answer? (run "-(1, 2)") -1 "diff exp")
(equal-answer? (run "zero? (0)") #t "zero? exp")
(equal-answer? (run "zero? (1)") #f "zero? exp")
(equal-answer? (run "if zero? (0) then 2 else 3") 2 "if exp")
(equal-answer? (run "if zero? (1) then 2 else 3") 3 "if exp")
(equal-answer? (run "i") 1 "built in var i is 1")
(equal-answer? (run "v") 5 "built in var i is 5")
(equal-answer? (run "x") 10 "built in var i is 10")
(equal-answer? (run "let a = 1 in -(a, x)") -9 "let exp")

; exer 3.6
(equal-answer? (run "minus(-(minus(5),9))") 14 "unary minus exp")

; exer 3.7
(equal-answer? (run "+(1, 2)") 3 "sum exp")

(equal-answer? (run "*(2, 3)") 6 "mul-exp")

; error on dividing 0
(equal-answer? (run "/(4, 2)") 2 "div-exp")

; exer 3.8
(equal-answer? (run "equal?(4, 2)") #f "equal?-exp")
(equal-answer? (run "equal?(2, 2)") #t "equal?-exp")

(equal-answer? (run "greater?(3, 2)") #t "greater?-exp")
(equal-answer? (run "greater?(3, 3)") #f "greater?-exp")
(equal-answer? (run "greater?(3, 4)") #f "greater?-exp")

(equal-answer? (run "less?(3, 2)") #f "less?-exp")
(equal-answer? (run "less?(3, 3)") #f "less?-exp")
(equal-answer? (run "less?(3, 4)") #t "less?-exp")

; exer 3.9
(equal-answer? (run "emptylist") '() "emptylist-exp")
(equal-answer? (run "cons(1, 2)") (cons 1 2) "cons-exp")

(equal-answer? (run "null?(emptylist)") #t "null?-exp")
(equal-answer? (run "null?(cons(1, 2))") #f "null?-exp")

(equal-answer? (run "car(cons(1, 2))") 1 "car-exp")
(equal-answer? (run "car(emptylist)") '() "car-exp")

(equal-answer? (run "cdr(cons(1, 2))") 2 "cdr-exp")
(equal-answer? (run "cdr(emptylist)") '() "cdr-exp")
