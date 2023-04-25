#lang eopl

(require rackunit)
(require racket)
(require "value.rkt")

(provide (all-defined-out))

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

(define (run-tests run)
  ; const
  (equal-answer? (run "1") 1 "const exp")

  ; diff
  (equal-answer? (run "-(1, 2)") -1 "diff exp")

  ; zero
  (equal-answer? (run "zero? (0)") #t "zero? exp")
  (equal-answer? (run "zero? (1)") #f "zero? exp")

  ; if
  (equal-answer? (run "if zero? (0) then 2 else 3") 2 "if exp")
  (equal-answer? (run "if zero? (1) then 2 else 3") 3 "if exp")

  ; var
  (equal-answer? (run "i") 1 "built in var i is 1")
  (equal-answer? (run "v") 5 "built in var i is 5")
  (equal-answer? (run "x") 10 "built in var i is 10")

  ; let-exp
  (equal-answer? (run "let a = 1 x = 2 in -(a, x)") -1 "let exp")
  (equal-answer? (run "let x = 30 in let x = -(x,1) y = -(x,2) in -(x,y)") 1 "let-exp with arbitrary number of vars")

  ; proc and call
  (equal-answer? (run "let f = proc (x) -(x,11) in (f (f 77))") 55 "proc-exp")
  (equal-answer? (run "(proc (f) (f (f 77)) proc (x) -(x,11))") 55 "iife")
  (equal-answer? (run "let f = proc(x) proc(y) -(x,-(0,y)) in ((f 3) 4)") 7 "nested proc")
  (equal-answer? (run "let f = proc(x, y) -(x,-(0,y)) in (f 3 4)") 7 "proc with multiple arguments")

  ; letrec
  (equal-answer? (run "
  letrec double(x)
    = if zero?(x) then 0 else -((double -(x,1)), -2)
      in (double 6)
  ") 12 "letrec-exp")

  (equal-answer? (run "
  letrec sum(x, y)
    = if zero?(x) then y else -((sum -(x,1) y), -1)
      in (sum 3 4)
  ") 7 "letrec-exp with multiple arguments")

  ; (odd 13) -> (even 12) -> (odd 11) -> ... -> (even 0) -> 1
  (equal-answer? (run "
  letrec
  even(x) = if zero?(x) then 1 else (odd -(x,1))
  odd(x) = if zero?(x) then 0 else (even -(x,1))
  in (odd 13)
  ") 1 "letrec-exp with multiple procedures")

  ; emptylist
  (equal-answer? (run "emptylist") '() "emptylist-exp")

  ; cons
  (equal-answer? (run "cons(1, 2)") (cons 1 2) "cons-exp")

  ; null?
  (equal-answer? (run "null?(emptylist)") #t "null?-exp")
  (equal-answer? (run "null?(cons(1, 2))") #f "null?-exp")

  ; car
  (equal-answer? (run "car(cons(1, 2))") 1 "car-exp")
  (equal-answer? (run "car(emptylist)") '() "car-exp")

  ; cdr
  (equal-answer? (run "cdr(cons(1, 2))") 2 "cdr-exp")
  (equal-answer? (run "cdr(emptylist)") '() "cdr-exp")

  ; list
  (equal-answer? (run "list(1, 2, 3)") (list 1 2 3) "list-exp")
  (equal-answer? (run "let x = 4 in list(x, -(x, 1), -(x, 3))") (list 4 3 1) "list-exp")

  ; begin
  (equal-answer? (run "
  begin
    x
  end
  ") 10 "begin-exp")

  ; assign
  (equal-answer? (run "
  begin
    set x = 11;
    x
  end
  ") 11 "assign-exp")

  )

(define (run-test-call-by-ref run)
  ; call by ref
  (equal-answer? (run "
  let f = proc (y) set y = 42
    in let g = 13
      in begin
        (f g);
        g
      end
  ") 42 "call-by-reference")
  )

(define (run-test-exception run)
  (equal-answer? (run "
  try 33 catch (m) 44
  ") 33 "simple succeed")

  (equal-answer? (run "
  try 33 catch (m) some-unbound-variable
  ") 33 "dont run handler til failure")

  (equal-answer? (run "
  try -(1, raise 44) catch (m) m
  ") 44 "simple failure")

  (check-exn exn:fail? (lambda () (run "-(1, raise 44)")))

  (equal-answer? (run "
  let f = proc (x) -(x, -(raise 99, 1))
    in try (f 33)
       catch (m) 44
  ") 44 "exceptions have dynamic scope")

  (equal-answer? (run "
  let f = proc (x) -(x, -(raise 99, 1))
    in -(try (f 33)
       catch (m) -(m,55), 1)
  ") 43 "handler in non tail recursive position")

  (equal-answer? (run "
  try raise -(raise 3, 1)
  catch (m) m
  ") 3 "nested raise")

  (equal-answer? (run "
  try try -(raise 23, 11)
      catch (m) -(raise 22, 1)
  catch (m) m
  ") 22 "propagate error 1")

  (equal-answer? (run "
  let f = proc (x) -(1, raise 99)
    in try
          try (f 44)
          catch (exc) (f 23)
       catch (exc) 11
  ") 11 "propagate error 2")

  (equal-answer? (run "
  let index = proc (n)
                letrec inner2 (lst)
                  % find position of n in lst else raise exception
                  = if null?(lst) then lst
                  else if zero?(-(car(lst), n)) then lst
                  else let v = (inner2 cdr(lst))
                       in v
                    in proc(lst)
                      try (inner2 lst)
                      catch (x) -1
              in ((index 3) list(2, 3, 4))
  ") '(3 4) "test-example-0.1")

  (equal-answer? (run "
  let index = proc (n)
                letrec inner2 (lst)
                  % find position of n in lst else raise exception
                  = if null?(lst) then raise 99
                  else if zero?(-(car(lst), n)) then 0
                  else let v = (inner2 cdr(lst))
                       in -(v, -1)
                    in proc(lst)
                      try (inner2 lst)
                      catch (x) -1
              in ((index 2) list(2, 3, 4))
  ") 0 "test-example-1.1")

  (equal-answer? (run "
  let index = proc (n)
                letrec inner2 (lst)
                  % find position of n in lst else raise exception
                  = if null?(lst) then raise 99
                  else if zero?(-(car(lst), n)) then 0
                  else let v = (inner2 cdr(lst))
                       in -(v, -1)
                    in proc(lst)
                      try (inner2 lst)
                      catch (x) -1
              in ((index 5) list(2, 3, 4))
  ") -1 "test-example-1.1")
  )

(define (run-test-wrong-number-of-args run)
  (equal-answer? (run "
  let f = proc (x) x
    in try (f 1 2)
       catch (m) 44
  ") 44 "wrong number of args, f accepts only single parameter x, get (1, 2)")
)

(define (run-test-division run)
  (equal-answer? (run "try div(4, 2) catch (m) 44") 2 "4 divieded by 2 is 2")
  (equal-answer? (run "try div(4, 0) catch (m) 44") 44 "throws error when divided by 0")
)
