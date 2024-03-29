#lang eopl

(require
  racket/lazy-require
  racket/list
  )
(lazy-require
 ["../shared/eval.rkt" (
                        eval-diff-exp
                        eval-zero?-exp
                        eval-if-exp
                        eval-let-exp
                        eval-letrec-exp
                        eval-null?-exp
                        eval-cons-exp
                        eval-car-exp
                        eval-cdr-exp
                        eval-list-exp
                        eval-begin-exp
                        )]
 ["../shared/store.rkt" (setref)]
 ["../shared/value.rkt" (expval->proc)]
 ["../shared/procedure.rkt" (apply-procedure/k)]
 ["interpreter.rkt" (value-of/k value-of-exps/k)]
 )

(provide (all-defined-out))


(define (end-cont) (lambda (val) val))

(define (apply-cont cont val)
  (cont val)
  )

(define (diff-cont saved-cont exp2 saved-env)
  (lambda (val1)
    (value-of/k exp2 saved-env
                (lambda (val2)
                  (apply-cont saved-cont (eval-diff-exp val1 val2))
                  ))
    )
  )

(define (zero?-cont saved-cont)
  (lambda (val1)
    (apply-cont saved-cont (eval-zero?-exp val1))
    )
  )

(define (if-cont saved-cont exp2 exp3 saved-env)
  (lambda (val)
    (value-of/k (eval-if-exp val exp2 exp3) saved-env saved-cont)
    )
  )

(define (let-cont saved-cont vars body saved-env)
  (lambda (val)
    (let ((vals val))
      (value-of/k body (eval-let-exp vars vals saved-env) saved-cont)
      )
    )
  )

(define (call-cont saved-cont rands saved-env)
  (lambda (rator)
    (value-of-exps/k rands saved-env
                     (lambda (args)
                       (let ((proc1 (expval->proc rator)))
                         (apply-procedure/k value-of/k proc1 args saved-cont)
                         )
                       )
                     )
    )
  )

(define (letrec-cont saved-cont p-names b-vars-list p-bodies body saved-env)
  (lambda (val)
    (value-of/k body (eval-letrec-exp p-names b-vars-list p-bodies saved-env) saved-cont)
    )
  )

(define (cons-cont saved-cont exp2 saved-env)
  (lambda (val1)
    (value-of/k exp2 saved-env
                (lambda (val2)
                  (apply-cont saved-cont (eval-cons-exp val1 val2))
                  )
                )
    )
  )

(define (null?-cont saved-cont)
  (lambda (val1)
    (apply-cont saved-cont (eval-null?-exp val1))
    )
  )

(define (car-cont saved-cont)
  (lambda (val1)
    (apply-cont saved-cont (eval-car-exp val1))
    )
  )

(define (cdr-cont saved-cont)
  (lambda (val1)
    (apply-cont saved-cont (eval-cdr-exp val1))
    )
  )

(define (list-cont saved-cont)
  (lambda (vals)
    (apply-cont saved-cont (eval-list-exp vals))
    )
  )

(define (begin-cont saved-cont)
  (lambda (vals)
    (apply-cont saved-cont (eval-begin-exp vals))
    )
  )

(define (set-rhs-cont saved-cont ref)
  (lambda (val)
    (setref ref val)
    (apply-cont saved-cont val)
    )
  )
