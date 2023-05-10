#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../shared/test.rkt" (run-test-mutex)]
 ["interpreter.rkt" (run)]
 )

(define (unsafe-counter)
    (run "
    let x = 0 in
        let incr_x = proc (id) proc (dummy) set x = -(x,-1)
            in begin
                spawn((incr_x 100));
                spawn((incr_x 200));
                spawn((incr_x 300))
            end
    ")
)

(unsafe-counter)


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

(safe-counter)
