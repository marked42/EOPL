#lang eopl

(require racket/lazy-require racket/list "value.rkt")
(lazy-require
 ["../shared/store.rkt" (deref vals->refs)]
 ["value.rkt" (num-val bool-val proc-val expval->num expval->bool is-null?-exp)]
 ["environment.rkt" (apply-env extend-mul-env build-circular-extend-env-rec-mul-vec)]
 ["procedure.rkt" (procedure)]
 )

(provide (all-defined-out))

(define (eval-const-exp num)
  (num-val num)
  )

(define (eval-diff-exp val1 val2)
  (let ((num1 (expval->num val1)) (num2 (expval->num val2)))
    (num-val (- num1 num2))
    )
  )

(define (eval-zero?-exp val1)
  (let ((num (expval->num val1)))
    (if (zero? num)
        (bool-val #t)
        (bool-val #f)
        )
    )
  )

(define (eval-if-exp val1 exp2 exp3)
  (let ((exp (if (expval->bool val1) exp2 exp3)))
    exp
    )
  )

(define (eval-var-exp saved-env var)
  (deref (apply-env saved-env var))
  )

(define (eval-let-exp vars vals saved-env)
  (extend-mul-env vars (vals->refs vals) saved-env)
  )

(define (eval-proc-exp first-var rest-vars body saved-env)
  (proc-val (procedure (cons first-var rest-vars) body saved-env))
  )

(define (eval-letrec-exp p-names b-vars-list p-bodies env)
  (build-circular-extend-env-rec-mul-vec p-names b-vars-list p-bodies env)
  )

(define (eval-emptylist-exp)
  (null-val)
  )

(define (eval-cons-exp val1 val2)
  (cell-val val1 val2)
  )

(define (eval-car-exp val1)
  (cell-val->first val1)
  )

(define (eval-cdr-exp val1)
  (cell-val->second val1)
  )

(define (eval-list-exp vals)
  (if (null? vals)
      (null-val)
      (let ((first (car vals)) (rest (cdr vals)))
        (cell-val first (eval-list-exp rest))
        )
      )
  )

(define (eval-begin-exp vals)
  (last vals)
  )

(define eval-null?-exp is-null?-exp)
