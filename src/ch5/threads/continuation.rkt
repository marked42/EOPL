#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../shared/basic.rkt" (identifier?)]
 ["../shared/eval.rkt" (
                        eval-diff-exp
                        eval-zero?-exp
                        eval-if-exp
                        eval-let-exp
                        eval-null?-exp
                        eval-cons-exp
                        eval-car-exp
                        eval-cdr-exp
                        eval-list-exp
                        eval-begin-exp
                        )]
 ["../shared/environment.rkt" (environment?)]
 ["../shared/store.rkt" (setref reference?)]
 ["../shared/value.rkt" (expval? expval->proc expval->mutex num-val)]
 ["../shared/expression.rkt" (expression?)]
 ["../shared/procedure.rkt" (apply-procedure/k)]
 ["scheduler.rkt" (set-final-answer! run-next-thread place-on-ready-queue! timer-expired? decrement-timer! new-thread get-the-time-remaining get-the-max-timeslice)]
 ["interpreter.rkt" (value-of/k value-of-exps/k value-of-exps-helper/k)]
 ["call.rkt" (eval-operand-call-by-value)]
 ["mutex.rkt" (wait-for-mutex signal-mutex)]
 )

(provide (all-defined-out))

(define-datatype continuation cont?
  (end-main-thread-cont)
  (end-subthread-cont)
  (diff-cont (saved-cont cont?) (exp2 expression?) (saved-env environment?))
  (diff-cont-1 (saved-cont cont?) (val1 expval?))
  (zero?-cont (saved-cont cont?))
  (if-cont (saved-cont cont?) (exp2 expression?) (exp3 expression?) (saved-env environment?))
  (exps-cont (saved-cont cont?) (exps (list-of expression?)) (vals (list-of expval?)) (saved-env environment?) (mapper procedure?))
  (let-cont (saved-cont cont?) (vars (list-of identifier?)) (body expression?) (env environment?))
  (call-cont (saved-cont cont?) (rands (list-of expression?)) (saved-env environment?))
  (call-cont-1 (saved-cont cont?) (rator expval?))

  (cons-cont (saved-cont cont?) (exp2 expression?) (saved-env environment?))
  (cons-cont-1 (saved-cont cont?) (val1 expval?))
  (null?-cont (saved-cont cont?))
  (car-cont (saved-cont cont?))
  (cdr-cont (saved-cont cont?))
  (list-cont (saved-cont cont?))

  (begin-cont (saved-cont cont?))

  (set-rhs-cont (saved-cont cont?) (ref reference?))

  (spawn-cont (saved-cont cont?))
  (wait-cont (saved-cont cont?))
  (signal-cont (saved-cont cont?))

  (print-cont (saved-cont cont?))

  (yield-cont (saved-cont cont?))
  )

(define (apply-cont cont val)
  (if (timer-expired?)
      (begin
        (place-on-ready-queue! (new-thread (lambda () (apply-cont cont val)) (get-the-max-timeslice)))
        (run-next-thread)
        )
      (begin
        (decrement-timer!)

        (cases continuation cont
          (end-main-thread-cont ()
                                (set-final-answer! val)
                                (run-next-thread)
                                )
          (end-subthread-cont () (run-next-thread))
          (diff-cont (saved-cont exp2 saved-env)
                     (value-of/k exp2 saved-env (diff-cont-1 saved-cont val))
                     )
          (diff-cont-1 (saved-cont val1)
                       (apply-cont saved-cont (eval-diff-exp val1 val))
                       )
          (zero?-cont (saved-cont)
                      (apply-cont saved-cont (eval-zero?-exp val))
                      )
          (if-cont (saved-cont exp2 exp3 saved-env)
                   (value-of/k (eval-if-exp val exp2 exp3) saved-env saved-cont)
                   )
          (exps-cont (saved-cont exps vals env mapper)
                     (value-of-exps-helper/k exps (append vals (list val)) env saved-cont mapper)
                     )
          (let-cont (saved-cont vars body saved-env)
                    (let ((vals val))
                      (value-of/k body (eval-let-exp vars vals saved-env) saved-cont)
                      )
                    )
          (call-cont (saved-cont rands saved-env)
                     (let ((rator val))
                       (value-of-exps/k rands saved-env (call-cont-1 saved-cont rator) eval-operand-call-by-value)
                       )
                     )
          (call-cont-1 (saved-cont rator)
                       (let ((proc1 (expval->proc rator)) (rands val))
                         (apply-procedure/k value-of/k proc1 rands saved-cont)
                         )
                       )
          (cons-cont (saved-cont exp2 env)
                     (value-of/k exp2 env (cons-cont-1 saved-cont val))
                     )
          (cons-cont-1 (saved-cont val1)
                       (let ((val2 val))
                         (apply-cont saved-cont (eval-cons-exp val1 val2))
                         )
                       )
          (null?-cont (saved-cont)
                      (apply-cont saved-cont (eval-null?-exp val))
                      )
          (car-cont (saved-cont)
                    (apply-cont saved-cont (eval-car-exp val))
                    )
          (cdr-cont (saved-cont)
                    (apply-cont saved-cont (eval-cdr-exp val))
                    )
          (list-cont (saved-cont)
                     (apply-cont saved-cont (eval-list-exp val))
                     )
          (begin-cont (saved-cont)
                      (let ((vals val))
                        (apply-cont saved-cont (eval-begin-exp vals))
                        )
                      )
          (set-rhs-cont (saved-cont ref)
                        (setref ref val)
                        (apply-cont saved-cont val)
                        )
          (spawn-cont (saved-cont)
                      (let ((proc1 (expval->proc val)))
                        (place-on-ready-queue!
                         (new-thread
                          (lambda () (apply-procedure/k value-of/k proc1 (list (num-val 28)) (end-subthread-cont)))
                          (get-the-max-timeslice)
                          )
                         )
                        (apply-cont saved-cont (num-val 73))
                        )
                      )
          (wait-cont (saved-cont) (wait-for-mutex (expval->mutex val) (lambda () (apply-cont saved-cont (num-val 52)))))
          (signal-cont (saved-cont)
                       (signal-mutex (expval->mutex val))
                       apply-cont saved-cont (num-val 53)
                       )
          (print-cont (saved-cont)
                      (eopl:pretty-print val)
                      (apply-cont saved-cont val)
                      )
          (yield-cont (saved-cont)
                      (place-on-ready-queue!
                       (new-thread
                        (lambda () (apply-cont saved-cont (num-val 99)))
                        (get-the-time-remaining)
                        )
                       )
                      (run-next-thread)
                      )
          )
        )
      )
  )
