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
 ["../shared/environment.rkt" (extend-env environment?)]
 ["../shared/store.rkt" (setref reference? newref)]
 ["../shared/value.rkt" (expval? expval->proc)]
 ["../shared/expression.rkt" (expression?)]
 ["../shared/procedure.rkt" (apply-procedure/k)]
 ["interpreter.rkt" (value-of/k value-of-exps/k value-of-exps-helper/k)]
 ["call.rkt" (eval-operand-call-by-value)]
 ["exception.rkt" (pop-try-cont)]
 )

(provide (all-defined-out))

(define-datatype continuation cont?
  (end-cont)
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

  (try-cont (saved-cont cont?) (var identifier?) (handler-exp expression?) (saved-env environment?))
  (raise-cont)
  )

(define (apply-cont cont val)
  (cases continuation cont
    (end-cont () val)
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
    (try-cont (saved-cont var handler-exp saved-env)
              ; uninstall handler when try cont succeeds or fails
              (pop-try-cont)
              (apply-cont saved-cont val)
              )
    (raise-cont ()
                ; should uninstall exception handler before evaluating handler-exp
                ; cause it may nest try-exp/raise-exp which changes try-conts stack
                (let ((top-try-cont (pop-try-cont)))
                  (cases continuation top-try-cont
                    (try-cont (saved-cont var handler-exp saved-env)
                              ; continue from try-exp denoted by saved-cont of top-try-cont
                              ; after evaluating handler-exp
                              (value-of/k handler-exp (extend-env var (newref val) saved-env) saved-cont)
                              )
                    (else eopl:error "invalid try cont" top-try-cont)
                    )
                  )
                )
    )
  )

(define (report-uncaught-exception val)
  (eopl:error 'uncaught-exception "Uncaught expcetion ~s " val)
  )