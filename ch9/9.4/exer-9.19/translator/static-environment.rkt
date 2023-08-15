#lang eopl

(require racket/list)

(provide (all-defined-out))

(define (empty-env) '())

(define (init-senv)
  (extend-senv-normal '(i)
                      (extend-senv-normal '(v)
                                          (extend-senv-normal '(x) (empty-env))
                                          )
                      )
  )

(define (extend-senv vars types senv)
  (cons (map (lambda (var type) (cons var type)) vars types) senv)
  )

(define (extend-senv-normal vars senv)
  (extend-senv vars (map (lambda (var) 'normal) vars) senv)
  )

(define (extend-senv-letrec vars senv)
  (extend-senv vars (map (lambda (var) 'letrec) vars) senv)
  )

(define (apply-senv senv var)
  (let loop ([senv senv] [depth 0])
    (if (null? senv)
        (report-unbound-var var)
        (let* ([top (car senv)] [index (index-where top (lambda (pair) (eqv? (car pair) var)))])
          (if index
              (cons depth index)
              (loop (cdr senv) (+ depth 1))
              )
          )
        )
    )
  )

(define (get-var-by-index senv index)
  (let ([depth (car index)] [offset (cdr index)])
    (list-ref (list-ref senv depth) offset)
    )
  )

(define (get-var-type-by-index senv index)
  (let ([var (get-var-by-index senv index)])
    (cdr var)
    )
  )

(define (report-unbound-var var)
  (eopl:error 'apply-senv "No binding for ~s" var)
  )
