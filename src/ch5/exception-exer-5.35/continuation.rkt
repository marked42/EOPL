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
 )

(provide (all-defined-out))

(define-datatype continuation cont?
  (end-cont)
  (diff-cont (saved-cont cont?) (saved-try-cont cont?) (exp2 expression?) (saved-env environment?))
  (diff-cont-1 (saved-cont cont?) (saved-try-cont cont?) (val1 expval?))
  (zero?-cont (saved-cont cont?) (saved-try-cont cont?))
  (if-cont (saved-cont cont?) (saved-try-cont cont?) (exp2 expression?) (exp3 expression?) (saved-env environment?))
  (exps-cont (saved-cont cont?) (saved-try-cont cont?) (exps (list-of expression?)) (vals (list-of expval?)) (saved-env environment?))
  (let-cont (saved-cont cont?) (saved-try-cont cont?) (vars (list-of identifier?)) (body expression?) (env environment?))
  (call-cont (saved-cont cont?) (saved-try-cont cont?) (rands (list-of expression?)) (saved-env environment?))
  (call-cont-1 (saved-cont cont?) (saved-try-cont cont?) (rator expval?))

  (cons-cont (saved-cont cont?) (saved-try-cont cont?) (exp2 expression?) (saved-env environment?))
  (cons-cont-1 (saved-cont cont?) (saved-try-cont cont?) (val1 expval?))
  (null?-cont (saved-cont cont?) (saved-try-cont cont?))
  (car-cont (saved-cont cont?) (saved-try-cont cont?))
  (cdr-cont (saved-cont cont?) (saved-try-cont cont?))
  (list-cont (saved-cont cont?) (saved-try-cont cont?))

  (begin-cont (saved-cont cont?) (saved-try-cont cont?))

  (set-rhs-cont (ref reference?) (saved-cont cont?) (saved-try-cont cont?))

  (try-cont (saved-cont cont?) (saved-try-cont cont?) (var identifier?) (handler-exp expression?) (saved-env environment?))
  (raise-cont (saved-cont cont?) (saved-try-cont cont?))
  )

(define (apply-cont cont val)
  (cases continuation cont
    (end-cont () val)
    (diff-cont (saved-cont saved-try-cont exp2 saved-env)
               (value-of/k exp2 saved-env (diff-cont-1 saved-cont saved-try-cont val))
               )
    (diff-cont-1 (saved-cont saved-try-cont val1)
                 (apply-cont saved-cont (eval-diff-exp val1 val))
                 )
    (zero?-cont (saved-cont saved-try-cont)
                (apply-cont saved-cont (eval-zero?-exp val))
                )
    (if-cont (saved-cont saved-try-cont exp2 exp3 saved-env)
             (value-of/k (eval-if-exp val exp2 exp3) saved-env saved-cont)
             )
    (exps-cont (saved-cont saved-try-cont exps vals env)
               (value-of-exps-helper/k exps (append vals (list val)) env saved-cont)
               )
    (let-cont (saved-cont saved-try-cont vars body saved-env)
              (let ((vals val))
                (value-of/k body (eval-let-exp vars vals saved-env) saved-cont)
                )
              )
    (call-cont (saved-cont saved-try-cont rands saved-env)
               (let ((rator val))
                 (value-of-exps/k rands saved-env (call-cont-1 saved-cont saved-try-cont rator))
                 )
               )
    (call-cont-1 (saved-cont saved-try-cont rator)
                 (let ((proc1 (expval->proc rator)) (rands val))
                   (apply-procedure/k value-of/k proc1 rands saved-cont)
                   )
                 )
    (cons-cont (saved-cont saved-try-cont exp2 env)
               (value-of/k exp2 env (cons-cont-1 saved-cont saved-try-cont val))
               )
    (cons-cont-1 (saved-cont saved-try-cont val1)
                 (let ((val2 val))
                   (apply-cont saved-cont (eval-cons-exp val1 val2))
                   )
                 )
    (null?-cont (saved-cont saved-try-cont)
                (apply-cont saved-cont (eval-null?-exp val))
                )
    (car-cont (saved-cont saved-try-cont)
              (apply-cont saved-cont (eval-car-exp val))
              )
    (cdr-cont (saved-cont saved-try-cont)
              (apply-cont saved-cont (eval-cdr-exp val))
              )
    (list-cont (saved-cont saved-try-cont)
               (apply-cont saved-cont (eval-list-exp val))
               )
    (begin-cont (saved-cont saved-try-cont)
                (let ((vals val))
                  (apply-cont saved-cont (eval-begin-exp vals))
                  )
                )
    (set-rhs-cont (ref saved-cont saved-try-cont)
                  (setref ref val)
                  (apply-cont saved-cont val)
                  )
    (try-cont (saved-cont saved-try-cont var handler-exp saved-env)
              ; returns normally
              (apply-cont saved-cont val)
              )
    (raise-cont (saved-cont saved-try-cont)
                (cases continuation saved-try-cont
                  (try-cont (saved-cont saved-try-cont var handler-exp saved-env)
                    (value-of/k handler-exp (extend-env var (newref val) saved-env) saved-cont)
                  )
                  (end-cont () (report-uncaught-exception val))
                  (else (eopl:error 'saved-try-cont "invalid saved-try-cont ~s " saved-try-cont))
                 )
                )
    )
  )

(define (get-saved-try-cont cont)
  (cases continuation cont
    (end-cont () cont)
    (diff-cont (saved-cont saved-try-cont exp2 saved-env) saved-try-cont)
    (diff-cont-1 (saved-cont saved-try-cont val1) saved-try-cont)
    (zero?-cont (saved-cont saved-try-cont) saved-try-cont)
    (if-cont (saved-cont saved-try-cont exp2 exp3 saved-env) saved-try-cont)
    (exps-cont (saved-cont saved-try-cont exps vals env) saved-try-cont)
    (let-cont (saved-cont saved-try-cont vars body saved-env) saved-try-cont)
    (call-cont (saved-cont saved-try-cont rands saved-env) saved-try-cont)
    (call-cont-1 (saved-cont saved-try-cont rator) saved-try-cont)
    (cons-cont (saved-cont saved-try-cont exp2 env) saved-try-cont)
    (cons-cont-1 (saved-cont saved-try-cont val1) saved-try-cont)
    (null?-cont (saved-cont saved-try-cont) saved-try-cont)
    (car-cont (saved-cont saved-try-cont) saved-try-cont)
    (cdr-cont (saved-cont saved-try-cont) saved-try-cont)
    (list-cont (saved-cont saved-try-cont) saved-try-cont)
    (begin-cont (saved-cont saved-try-cont) saved-try-cont)
    (set-rhs-cont (ref saved-cont saved-try-cont) saved-try-cont)
    ; return current try-cont
    (try-cont (saved-cont saved-try-cont var handler-exp saved-env) cont)
    (raise-cont (saved-cont saved-try-cont) saved-try-cont)
    (else (eopl:error 'get-saved-try-cont "invalid cont ~s " cont))
    )
  )

(define (report-uncaught-exception val)
  (eopl:error 'uncaught-exception "Uncaught expcetion ~s " val)
  )
