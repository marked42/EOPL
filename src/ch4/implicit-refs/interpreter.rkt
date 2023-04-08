#lang eopl

(require racket/lazy-require "value.rkt" "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-mul-env
                     build-circular-extend-env-rec-mul-vec
                     )]
 ["store.rkt" (initialize-store! newref deref setref vals->refs)]
 ["procedure.rkt" (apply-procedure procedure)])

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  (initialize-store!)
  (cases program prog
    (a-program (exp1) (value-of-exp exp1 (init-env)))
    )
  )

; get value of a list of exp
(define (value-of-exps exps env)
  (map (lambda (exp) (value-of-exp exp env)) exps)
  )

(define (value-of-exp exp env)
  (cases expression exp
    ; number constant
    (const-exp (num) (num-val num))
    ; subtraction of two numbers
    (diff-exp (exp1 exp2)
              (let ((val1 (value-of-exp exp1 env))
                    (val2 (value-of-exp exp2 env)))
                (let ((num1 (expval->num val1))
                      (num2 (expval->num val2)))
                  (num-val (- num1 num2))
                  )
                )
              )
    ; true only if exp1 is number 0
    (zero?-exp (exp1)
               (let ((val (value-of-exp exp1 env)))
                 (let ((num (expval->num val)))
                   (if (zero? num)
                       (bool-val #t)
                       (bool-val #f)
                       )
                   )
                 )
               )
    (if-exp (exp1 exp2 exp3)
            (let ((val1 (value-of-exp exp1 env)))
              (if (expval->bool val1)
                  (value-of-exp exp2 env)
                  (value-of-exp exp3 env)
                  )
              )
            )
    (var-exp (var)
             (deref (apply-env env var))
             )
    (let-exp (vars exps body)
             (let ((vals (value-of-exps exps env)))
               (value-of-exp body (extend-mul-env vars (vals->refs vals) env))
               )
             )
    (letrec-exp (p-names b-vars-list p-bodies body)
                (let ((new-env (build-circular-extend-env-rec-mul-vec p-names b-vars-list p-bodies env)))
                  (value-of-exp body new-env)
                  )
                )
    (proc-exp (first-var rest-vars body)
              (proc-val (procedure (cons first-var rest-vars) body env))
              )
    (call-exp (rator rands)
              (let ((rator-val (value-of-exp rator env)) (rand-vals (value-of-exps rands env)))
                (let ((proc1 (expval->proc rator-val)))
                  (apply-procedure proc1 (vals->refs rand-vals))
                  )
                )
              )
    (begin-exp (first others)
               (letrec ((loop (lambda (exps)
                                (if (null? exps)
                                    #f
                                    (let ((first-exp (car exps)) (rest-exps (cdr exps)))
                                      ; always calculate first exp cause it may has side effects
                                      (let ((first-val (value-of-exp first-exp env)))
                                        (if (null? rest-exps)
                                            first-val
                                            (loop rest-exps)
                                            )
                                        )
                                      )
                                    )
                                )
                              ))
                 (loop (cons first others))
                 )
               )
    (assign-exp (var exp1)
      (let ((val1 (value-of-exp exp1 env)))
        (setref (apply-env env var) val1)
      )
    )
    (else 42)
    )
  )

(define (report-cond-no-true-predicate exp)
  (eopl:error 'cond-exp "No true cond for exp ~s" exp)
  )

(define (report-cond-invalid-predicate exp)
  (eopl:error 'cond-exp "invalid predicate " exp)
  )
