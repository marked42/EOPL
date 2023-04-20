#lang eopl

(require
  racket/lazy-require
  racket/list
  )
(lazy-require
 ["../shared/basic.rkt" (identifier?)]
 ["../shared/eval.rkt" (
                        eval-diff-exp
                        eval-zero?-exp
                        eval-null?-exp
                        eval-cons-exp
                        eval-if-exp
                        eval-car-exp
                        eval-cdr-exp
                        build-list-from-vals
                        )]
 ["../shared/environment.rkt" (
                               extend-mul-env
                               environment?
                               )]
 ["../shared/store.rkt" (vals->refs setref reference?)]
 ["../shared/value.rkt" (expval? expval->proc cell-val)]
 ["../shared/expression.rkt" (expression?)]
 ["interpreter.rkt" (value-of/k value-of-exps/k)]
 ["../shared/procedure.rkt" (apply-procedure/k)]
 ["call.rkt" (eval-call-by-ref-operand)]
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

  (set-rhs-cont (ref reference?) (saved-cont cont?))
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
               (value-of-exps/k exps (append vals (list val)) env saved-cont mapper)
               )
    (let-cont (saved-cont vars body env)
              (let ((vals val))
                (value-of/k body (extend-mul-env vars (vals->refs vals) env) saved-cont)
                )
              )
    (call-cont (saved-cont rands saved-env)
                   (let ((rator val))
                     (value-of-exps/k rands '() saved-env (call-cont-1 saved-cont rator) eval-call-by-ref-operand)
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
                   (apply-cont saved-cont (build-list-from-vals val))
                   )
    (begin-cont (saved-cont)
                    (let ((vals val))
                      (apply-cont saved-cont (last vals))
                      )
                    )
    (set-rhs-cont (ref saved-cont)
                  (setref ref val)
                  (apply-cont saved-cont val)
                  )
    )
  )
