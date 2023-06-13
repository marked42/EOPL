#lang eopl

(require racket/list)
(provide (all-defined-out))

(define (empty-env) '())

(define (extend-env var val env)
  (cons (cons var val) env)
  )

; new stuff
(define (has-binding? env search-var)
  (if (null? env)
      #f
      (let* ([top (first env)] [saved-var (car top)])
        (if (eqv? search-var saved-var)
            #t
            (has-binding? (cdr env) search-var)
            )
        )
      )
  )

(define (apply-env env search-var)
  (if (null? env)
      (report-no-binding-found search-var)
      (let* ([top (first env)] [saved-var (car top)] [saved-val (cdr top)])
        (if (eqv? search-var saved-var)
            saved-val
            (apply-env (cdr env) search-var)
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
