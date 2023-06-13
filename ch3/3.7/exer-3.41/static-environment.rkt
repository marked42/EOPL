#lang eopl

(require racket/list)

(provide (all-defined-out))

(define (empty-env) '())

(define (init-senv)
  (extend-senv '(i)
               (extend-senv '(v)
                            (extend-senv '(x) (empty-env))
                            )
               )
  )

(define (extend-senv vars senv)
  (cons vars senv)
  )

(define (apply-senv senv var)
  (let loop ([senv senv] [depth 0])
    (if (null? senv)
        (report-unbound-var var)
        (let* ([top (car senv)] [index (index-of top var)])
          (if index
              (cons depth index)
              (loop (cdr senv) (+ depth 1))
              )
          )
        )
    )
  )

(define (report-unbound-var var)
  (eopl:error 'apply-senv "No binding for ~s" var)
  )
