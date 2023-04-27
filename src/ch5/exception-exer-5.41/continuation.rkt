#lang eopl

(require racket/lazy-require racket/list)
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

(define (end-cont)
  (cons
    (lambda (val) val)
    (lambda () (report-uncaught-exception))
  )
)

(define (diff-cont saved-cont exp2 saved-env)
  (cons
    (lambda (val)
      (value-of/k exp2 saved-env (diff-cont-1 saved-cont val))
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (diff-cont-1 saved-cont val1)
  (cons
    (lambda (val)
      (apply-cont saved-cont (eval-diff-exp val1 val))
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (zero?-cont saved-cont)
  (cons
    (lambda (val) (apply-cont saved-cont (eval-zero?-exp val)))
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (if-cont saved-cont exp2 exp3 saved-env)
  (cons
    (lambda (val)
      (value-of/k (eval-if-exp val exp2 exp3) saved-env saved-cont)
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (exps-cont saved-cont exps vals env)
  (cons
    (lambda (val)
            (value-of-exps-helper/k exps (append vals (list val)) env saved-cont)
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (let-cont saved-cont vars body saved-env)
  (cons
    (lambda (val)
            (let ((vals val))
              (value-of/k body (eval-let-exp vars vals saved-env) saved-cont)
              )
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (call-cont saved-cont rands saved-env)
  (cons
    (lambda (val)
            (let ((rator val))
              (value-of-exps/k rands saved-env (call-cont-1 saved-cont rator))
              )
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (call-cont-1 saved-cont rator)
  (cons
    (lambda (val)
            (let ((proc1 (expval->proc rator)) (rands val))
              (apply-procedure/k value-of/k proc1 rands saved-cont)
              )
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (cons-cont saved-cont exp2 env)
  (cons
    (lambda (val)
            (value-of/k exp2 env (cons-cont-1 saved-cont val))
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (cons-cont-1 saved-cont val1)
  (cons
    (lambda (val)
            (let ((val2 val))
              (apply-cont saved-cont (eval-cons-exp val1 val2))
              )
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (null?-cont saved-cont)
  (cons
    (lambda (val)
            (apply-cont saved-cont (eval-null?-exp val))
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (car-cont saved-cont)
  (cons
    (lambda (val)
            (apply-cont saved-cont (eval-car-exp val))
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (cdr-cont saved-cont)
  (cons
    (lambda (val)
            (apply-cont saved-cont (eval-cdr-exp val))
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (list-cont saved-cont)
  (cons
    (lambda (val)
            (apply-cont saved-cont (eval-list-exp val))
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (begin-cont saved-cont)
  (cons
    (lambda (val)
            (let ((vals val))
              (apply-cont saved-cont (eval-begin-exp vals))
              )
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (set-rhs-cont saved-cont ref)
  (cons
    (lambda (val)
            (setref ref val)
            (apply-cont saved-cont val)
    )
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (try-cont saved-cont var handler-exp saved-env)
  (cons
    (lambda (val)
            ; returns normally
            (apply-cont saved-cont val)
    )
    (lambda (val)
            ; returns normally
            (value-of/k handler-exp (extend-env var (newref val) saved-env) saved-cont)
    )
  )
)

(define (raise-cont saved-cont)
  (cons
    (lambda (val) (apply-handler saved-cont val))
    (lambda (val) (apply-handler saved-cont val))
  )
)

(define (apply-cont cont val) ((car cont) val))

; search upward linearly for corresponding try-exp
(define (apply-handler saved-cont val) ((cdr saved-cont) val))

(define (report-uncaught-exception)
  (eopl:error 'uncaught-exception "Uncaught expcetion ~s ")
  )
