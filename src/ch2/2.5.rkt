#lang eopl

(provide (all-defined-out))

(define (empty-env) '())

; exer 2.8
(define (empty-env? env) (null? env))

(define (extend-env var val env)
  (cons (cons var val) env)
  )

(define (apply-env env var)
  (if (null? env)
      (report-no-binding-found var)
      (let ((saved-var (caar env)) (saved-val (cadar env)) (saved-env (cadr env)))
        (if (eqv? saved-var var)
            saved-val
            (apply-env saved-env var)
            )
        )
      )
  )

; exer 2.9
(define (has-binding env var)
  (if (null? env)
      #f
      (let ((saved-var (caar env)) (saved-env (cadr env)))
        (if (eqv? saved-var var)
            #t
            (apply-env saved-env var)
            )
        )
      )
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-env "No binding for ~s" var)
  )
