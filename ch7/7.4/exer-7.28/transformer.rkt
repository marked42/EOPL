#lang eopl

(require racket/lazy-require "expression.rkt")

(provide transform-let-exp)

(define (transform-let-exp exp)
  (let loop ([exp exp] [env (init-env)])
    (cases expression exp
      (const-exp (num) exp)
      (var-exp (var1)
              (let ([val (apply-env env var1)])
                (if (expression? val)
                  val
                  exp
                  )
                )
              )
      (diff-exp (exp1 exp2)
                (diff-exp (loop exp1 env) (loop exp2 env))
                )
      (zero?-exp (exp1)
                  (zero?-exp (loop exp1 env))
                  )
      (if-exp (exp1 exp2 exp3)
              (if-exp (loop exp1 env) (loop exp2 env) (loop exp3 env))
              )
      (let-exp (var exp1 body)
              (loop body (extend-env var (loop exp1 env) env))
              )
      (proc-exp (var var-type body)
                (proc-exp var var-type (loop body (extend-env var #t env)))
                )
      (call-exp (rator rand)
                (call-exp (loop rator env) (loop rand env))
                )
      (letrec-exp (p-result-type p-name b-var b-var-type p-body body)
                  (let ([new-env (extend-env-rec p-name b-var p-body env)])
                    (letrec-exp
                      p-result-type p-name b-var b-var-type
                      (loop p-body (extend-env b-var #t new-env))
                      (loop body new-env)
                      )
                    )
                  )
      (else (eopl:error 'loop "unsupported expression type ~s" exp))
      )
    )
)

(define-datatype environment environment?
  (empty-env)
  (extend-env
   (var symbol?)
   (val (lambda (val) (or (boolean? val) (expression? val))))
   (saved-env environment?)
   )
  (extend-env-rec
   (p-name symbol?)
   (b-var symbol?)
   (p-body expression?)
   (saved-env environment?)
   )
  )

(define (init-env)
  (extend-env 'i #t (extend-env 'v #t (extend-env 'x #t (empty-env))))
  )

(define (apply-env env search-var)
  (cases environment env
    (extend-env (var val saved-env)
                (if (eqv? search-var var)
                    val
                    (apply-env saved-env search-var)
                    )
                )
    (extend-env-rec (p-name b-var p-body saved-env)
                    (if (eqv? search-var p-name)
                        #t
                        (apply-env saved-env search-var)
                        )
                    )
    (else #f)
    )
  )
