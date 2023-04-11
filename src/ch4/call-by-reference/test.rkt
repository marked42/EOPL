#lang eopl

(require rackunit)
(require racket)
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
      (else
       (eopl:error 'sloppy->expval
                   "Can't convert sloppy value to expval: ~s"
                   sloppy-val)))))

(equal-answer? (run "
let p = proc (x) set x = 4
      in let a = 3
         in begin (p a); a end
") 4 "call by reference")


(equal-answer? (run "
let f = proc (x) set x = 44
  in let g = proc (y) (f y)
    in let z = 55
      in begin (g z); z end
") 44 "call by reference")

(equal-answer? (run "
let swap = proc (x) proc (y) let temp = x
                  in begin
                      set x = y;
                      set y = temp
                     end
      in let a = 33
         in let b = 44
            in begin
                ((swap a) b);
                -(a,b)
            end
") 11 "call by reference")

(equal-answer? (run "
let b = 3
in let p = proc (x) proc(y)
                  begin
                   set x = 4;
                   y
                  end
         in ((p b) b)
") 4 "aliasing")

(equal-answer? (run "
let a = 1
  in let b = a
    in begin
      set b = 3;
      a
    end
") 1 "normal let-exp")

(equal-answer? (run "
let a = 1
  in letref b = a
    in begin
      set b = 3;
      a
    end
") 3 "leftref-exp")

(equal-answer? (run "
let a = newarray(2, -99)
    in begin
      arrayref(a, 0)
    end
") -99 "new array")

(equal-answer? (run "
let setx = proc (x) set x = 3
  in let a = newarray(2, -99)
      in begin
        (setx arrayref(a, 1));
        arrayref(a, 1)
      end
") 3 "new array")

(equal-answer? (run "
let swap = proc (x, y)
            let temp = x
              in begin
                  set x = y;
                  set y = temp
                  end
    set3 = proc (x) set x = 3
    set4 = proc (x) set x = 4
      in let a = newarray(2, -99)
          in begin
            (set3 arrayref(a, 0));
            (set4 arrayref(a, 1));
            (swap arrayref(a, 0) arrayref(a, 1));
            -(arrayref(a, 0), arrayref(a, 1))
          end
") 1 "swap array")
