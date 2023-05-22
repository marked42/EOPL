#lang eopl

(require racket/lazy-require "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env
                     extend-env-rec*
                     )]
 ["continuation.rkt" (apply-cont end-cont)]
 ["value.rkt" (num-val bool-val proc-val expval->num expval->bool expval->proc)]
 ["parser.rkt" (scan&parse)]
 ["transformer.rkt" (cps-of-program)]
 ["procedure.rkt" (apply-procedure procedure)])

(provide (all-defined-out))

(define (run str)
  (let ((prog (scan&parse str)))
    (let ((cps-prog (cps-of-program prog)))
      (eopl:pretty-print cps-prog)
      (value-of-program cps-prog)
      )
    )
  )

(define (value-of-program cps-prog)
  (cases cps-program cps-prog
    (cps-a-program (exp1)
                   (value-of/k exp1 (init-env) (end-cont))
                   )
    )
  )

(define (value-of/k exp env cont)
  (cases tfexp exp
    (simple-exp->exp (simple)
                     (apply-cont cont (value-of-simple-exp simple env))
                     )
    (cps-if-exp (exp1 exp2 exp3)
                (let ((val1 (value-of-simple-exp exp1 env)))
                  (if (expval->bool val1)
                      (value-of/k exp2 env cont)
                      (value-of/k exp3 env cont)
                      )
                  )
                )
    (cps-let-exp (var exp1 body)
                 (let ((val (value-of-simple-exp exp1 env)))
                   (value-of/k body (extend-env var val env) cont)
                   )
                 )
    (cps-letrec-exp (p-names b-varss p-bodies body)
                    (let ((new-env (extend-env-rec* p-names b-varss p-bodies env)))
                      (value-of/k body new-env cont)
                      )
                    )
    (cps-call-exp (rator rands)
                  (let ((rator-val (value-of-simple-exp rator env)) (rand-vals (value-of-simple-exps rands env)))
                    (let ((proc1 (expval->proc rator-val)))
                      (apply-procedure proc1 rand-vals cont)
                      )
                    )
                  )
    (else (eopl:error 'value-of/k "invalid expression ~s" exp))
    )
  )

(define (value-of-simple-exp exp1 env)
  (cases simple-expression exp1
    (cps-const-exp (num) (num-val num))
    (cps-var-exp (var) (apply-env env var))
    (cps-diff-exp (exp1 exp2)
                  (let ((val1 (value-of-simple-exp exp1 env))
                        (val2 (value-of-simple-exp exp2 env)))
                    (let ((num1 (expval->num val1))
                          (num2 (expval->num val2)))
                      (num-val (- num1 num2))
                      )
                    )
                  )
    ; true only if exp1 is number 0
    (cps-zero?-exp (exp1)
                   (let ((val (value-of-simple-exp exp1 env)))
                     (let ((num (expval->num val)))
                       (if (zero? num)
                           (bool-val #t)
                           (bool-val #f)
                           )
                       )
                     )
                   )
    (cps-proc-exp (vars body)
                  (proc-val (procedure vars body env))
                  )
    (cps-sum-exp (exps)
                 (let ((nums (map
                              (lambda (exp)
                                (expval->num
                                 (value-of-simple-exp exp env)))
                              exps)))
                   (num-val
                    (let sum-loop ((nums nums))
                      (if (null? nums) 0
                          (+ (car nums) (sum-loop (cdr nums))))))))
    (else (eopl:error 'value-of-simple-exp "unsupported simple-expression ~s " exp1))
    )
  )

(define (value-of-simple-exps exps env)
  (map (lambda (exp1) (value-of-simple-exp exp1 env)) exps)
  )
