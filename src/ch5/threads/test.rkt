#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../shared/test.rkt" (run-test-mutex equal-answer?)]
 ["interpreter.rkt" (run)]
 )

; two threads showing interleaved output
(define (two-non-cooperating-threads)
  (run "
    letrec noisy (l) = if null?(l)
                    then 0
                    else begin print(car(l)); (noisy cdr(l)) end
        in begin
            spawn(proc (d) (noisy list(1,2,3,4,5)));
            spawn(proc (d) (noisy list(6,7,8,9,10)));
            print(100);
            33
        end
    ")
  )

(define (busywait)
  (run "
let buffer = 0
  in let producer = proc (n)
                      letrec wait1 (k) = if zero?(k)
                                      then set buffer = n
                                      else begin
                                          print(-(k,-200));
                                          (wait1 -(k,1))
                                      end
                        in (wait1 5)
      in let consumer = proc (d)
                          letrec busywait (k) = if zero?(buffer)
                                                then begin
                                                      print(-(k,-100));
                                                      (busywait -(k,-1))
                                                    end
                                                else buffer
                            in (busywait 0)
        in begin
          spawn(proc (d) (producer 44));
          print(300);
          (consumer 86)
        end
  ")
  )

; TODO: probably wrong
(define (synchronize)
  (run "
let buffer = 0 m = mutex()
  in let producer = proc (n)
                      letrec wait1 (k) = if zero?(k)
                                      then begin
                                        set buffer = n;
                                        signal(m)
                                      end
                                      else begin
                                          print(-(k,-200));
                                          (wait1 -(k,1))
                                      end
                        in begin
                          wait(m);
                          (wait1 5)
                        end
      in let consumer = proc (d)
                          letrec busywait (k) = if zero?(buffer)
                                                then begin
                                                      print(-(k,-100));
                                                      (busywait -(k,-1))
                                                    end
                                                else buffer
                            in begin
                              wait(m);
                              (busywait 0)
                            end
        in begin
          spawn(proc (d) (producer 44));
          print(300);
          (consumer 86)
        end
  ")
  )

(define (unsafe-counter)
  (run "
    let x = 0 in
        let incr_x = proc (id) proc (dummy) begin set x = -(x,-1); print(x) end
            in begin
                spawn((incr_x 100));
                spawn((incr_x 200));
                spawn((incr_x 300))
            end
    ")
  )

(define (safe-counter)
  (run "
let x = 0
      in let mut = mutex()
      in let incr_x = proc (id)
                       proc (dummy)
                        begin
                         wait(mut);
                         set x = -(x,-1);
                         signal(mut)
end
      in begin
          spawn((incr_x 100));
          spawn((incr_x 200));
          spawn((incr_x 300))
end
    ")
  )

(define (test-yield)
  (equal-answer? (run "
let x = 1
  in let y = yield()
    in y
") 99 "yield-exp")
  )

(define (test-thread-identifier)
  (equal-answer? (run "
let x = spawn(proc (y) y)
    in x
") 1 "spawn return first child thread identifier 1, main thread is 0")
  )

(define (test-lock-race)
  (equal-answer? (run "
let m = mutex()
  in letrec prod (n) = letrec busy (y) = begin
                                        wait(m);
                                        print(n);
                                        print(y);
                                        signal(m);
                                        (busy -(y,-2))
                                      end
                          in (busy n)
    in let t1 = spawn((prod 0))
      in let t2 = spawn((prod 1))
        in 1
") 1 "lock")
  )
(test-lock-race)
