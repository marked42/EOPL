#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")
(lazy-require
 ["basic.rkt" (identifier? report-expval-extractor-error report-no-binding-found)]
 )

(provide (all-defined-out))

(define expr 'uninitialized)
(define env 'uninitialized)
(define cont 'uninitialized)
(define val 'uninitialized)
(define proc1 'uninitialized)

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  (cases program prog
    (a-program (exp1)
               (set! expr exp1)
               (set! env (init-env))
               (set! cont (end-cont))
               (value-of/k)
               ; return val which stores the result
               val
               )
    )
  )

(define (value-of/k)
  (cases expression expr
    ; number constant
    (const-exp (num)
               (set! val (num-val num))
               ; useless
               ; (set! cont cont)
               (apply-cont)
               )
    ; subtraction of two numbers
    (diff-exp (exp1 exp2)
              (set! expr exp1)
              ; useless
              ; (set! env env)
              (set! cont (diff-cont cont exp2 env))
              (value-of/k)
              )
    ; true only if exp1 is number 0
    (zero?-exp (exp1)
               (set! expr exp1)
               ; useless
               ; (set! env env)
               (set! cont (zero?-cont cont))
               (value-of/k)
               )
    (if-exp (exp1 exp2 exp3)
            (set! expr exp1)
            ; useless
            ; (set! env env)
            (set! cont (if-cont cont exp2 exp3 env))
            (value-of/k)
            )
    (var-exp (var)
             (set! val (apply-env env var))
             ; useless
             ; (set! cont cont)
             (apply-cont)
             )
    (let-exp (var exp1 body)
             (set! cont (let-cont cont var body env))
             (set! expr exp1)
             ; useless
             ; (set! env env)
             (value-of/k)
             )
    (proc-exp (var body)
              (set! val (proc-val (procedure var body env)))
              ; useless
              ; (set! cont cont)
              (apply-cont)
              )
    (call-exp (rator rand)
              (set! expr rator)
              ; useless
              ; (set! env env)
              (set! cont (call-cont cont rand env))
              (value-of/k)
              )
    (else 42)
    )
  )

(define-datatype continuation cont?
  (end-cont)
  (diff-cont (saved-cont cont?) (exp2 expression?) (saved-env environment?))
  (diff-cont-1 (saved-cont cont?) (val1 expval?))
  (zero?-cont (saved-cont cont?))
  (if-cont (saved-cont cont?) (exp2 expression?) (exp3 expression?) (saved-env environment?))
  (let-cont (saved-cont cont?) (var identifier?) (body expression?) (env environment?))
  (call-cont (saved-cont cont?) (rands expression?) (saved-env environment?))
  (call-cont-1 (saved-cont cont?) (rator expval?))
  )

(define (apply-cont)
  (cases continuation cont
    ; end-cont is useless
    ; (end-cont () val)
    (diff-cont (saved-cont exp2 saved-env)
               (set! cont (diff-cont-1 saved-cont val))
               (set! expr exp2)
               (set! env saved-env)
               (value-of/k)
               )
    (diff-cont-1 (saved-cont val1)
                 (set! cont saved-cont)
                 (let ((num1 (expval->num val1)) (num2 (expval->num val)))
                   (set! val (num-val (- num1 num2)))
                   (apply-cont)
                   )
                 )
    (zero?-cont (saved-cont)
                (set! val (let ((num (expval->num val)))
                            (if (zero? num)
                                (bool-val #t)
                                (bool-val #f)
                                )
                            )
                      )
                (set! cont saved-cont)
                (apply-cont)
                )
    (if-cont (saved-cont exp2 exp3 saved-env)
             (set! expr (if (expval->bool val) exp2 exp3))
             (set! cont saved-cont)
             (set! env saved-env)
             (value-of/k)
             )
    (let-cont (saved-cont var body saved-env)
              (set! cont saved-cont)
              (set! env (extend-env var val saved-env))
              (set! expr body)
              (value-of/k)
              )
    (call-cont (saved-cont rand saved-env)
               (set! expr rand)
               (set! env saved-env)
               (set! cont (call-cont-1 saved-cont val))
               (value-of/k)
               )
    (call-cont-1 (saved-cont rator)
                 (set! proc1 (expval->proc rator))
                 (set! cont saved-cont)
                 (apply-procedure/k)
                 )
    (else "error")
    )
  )

(define-datatype proc proc?
  (procedure
   (var identifier?)
   (body expression?)
   (saved-env environment?)
   )
  )

(define (apply-procedure/k)
  (cases proc proc1
    (procedure (var body saved-env)
               (set! expr body)
               (set! env (extend-env var val saved-env))
               (value-of/k)
               )
    )
  )

(define-datatype expval expval?
  (num-val (num number?))
  (bool-val (bool boolean?))
  (proc-val (proc1 proc?))
  )

(define (expval->num val)
  (cases expval val
    (num-val (num) num)
    (else (report-expval-extractor-error 'num val))
    )
  )

(define (expval->bool val)
  (cases expval val
    (bool-val (bool) bool)
    (else (report-expval-extractor-error 'bool val))
    )
  )

(define (expval->proc val)
  (cases expval val
    (proc-val (proc1) proc1)
    (else (report-expval-extractor-error 'proc val))
    )
  )

(define-datatype environment environment?
  (empty-env)
  (extend-env
   (var identifier?)
   (val expval?)
   (env environment?)
   )
  )

; use a vec to build circular refs to avoid create same proc-val multiple times

(define (init-env)
  (extend-env 'i (num-val 1)
              (extend-env 'v (num-val 5)
                          (extend-env 'x (num-val 10)
                                      (empty-env)
                                      )
                          )
              )
  )

(define (apply-env env search-var)
  (cases environment env
    (extend-env (var val saved-env)
                (if (eqv? search-var var)
                    val
                    (apply-env saved-env search-var)
                    )
                )
    (else (report-no-binding-found search-var))
    )
  )
