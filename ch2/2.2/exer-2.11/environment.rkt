#lang eopl

(require racket/list)
(provide (all-defined-out))

(define (empty-env) '())

(define (extend-env var val env)
  (cons (cons (list var) (list val)) env)
  )

(define (extend-env* vars vals env)
  (cons (cons vars vals) env)
  )

(define (apply-env env search-var)
  (if (null? env)
      (report-no-binding-found search-var)
      (let* ([top-rib (first env)] [saved-vars (car top-rib)] [saved-vals (cdr top-rib)])
        (let ([index (index-of saved-vars search-var)])
          (if index
              (list-ref saved-vals index)
              (apply-env (cdr env) search-var)
              )
          )
        )
      )
  )

(define (report-no-binding-found search-var)
  (eopl:error 'apply-env "No binding for ~s" search-var)
  )


(define (report-invalid-env env)
  (eopl:error 'apply-env "Bad environment: ~s" env)
  )
