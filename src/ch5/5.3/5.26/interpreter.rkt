#lang eopl

(require
  racket/lazy-require
  "../../base/expression.rkt"
  "../../base/procedure.rkt"
  "../../base/continuation.rkt"
  )
(lazy-require
 ["../../base/parser.rkt" (scan&parse)]
 ["../../base/value.rkt" (num-val bool-val proc-val expval->num expval->bool expval->proc)]
 ["../../base/environment.rkt" (init-env apply-env extend-env)]
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

(define (trampoline pc)
  (if pc (trampoline (pc)) val)
  )

(define (value-of-program prog)
  (cases program prog
    (a-program (exp1)
               (set! expr exp1)
               (set! env (init-env))
               (set! cont (end-cont))
               (trampoline value-of/k)
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
    (else (eopl:error 'value-of/k "unsupported expression ~s" expr))
    )
  )

(define (apply-cont)
  (cases continuation cont
    ; return #f to stop trampoline recursive call
    (end-cont () #f)
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
                 ; return apply-procedure/k to unwind stack to top,
                 ; trampoline will trigger another round by calling apply-procedure/k
                 apply-procedure/k
                 )
    (else (eopl:error 'apply-cont "unsupported continuation ~s " cont))
    )
  )

(define (apply-procedure/k)
  (cases proc proc1
    (procedure (var body saved-env)
               (set! expr body)
               (set! env (extend-env var val saved-env))
               (value-of/k)
               )
    (else (eopl:error 'apply-procedure/k "unsupported procedure ~s " proc1))
    )
  )
