#lang eopl

(require racket/lazy-require racket/list "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env*
                     extend-env-rec*
                     )]
 ["value.rkt" (num-val expval->num bool-val expval->bool proc-val expval->proc null-val is-uninitialized?)]
 ["procedure.rkt" (procedure apply-procedure)]
 ["store.rkt" (initialize-store! newref deref setref!)]
 )

(provide (all-defined-out))

(define (run str)
  (result-of-program (scan&parse str))
  )

(define (result-of-program prog)
  ; new stuff
  (initialize-store!)
  (cases program prog
    (a-program (body) (result-of body (init-env)))
    )
  )

(define (result-of stat env)
  (cases statement stat
    (assign-statement (var exp1)
                      (let ([val1 (value-of-exp exp1 env)])
                        (setref! (apply-env env var) val1)
                        val1
                        )
                      )
    (print-statement (exp1)
                     (let ([val1 (value-of-exp exp1 env)])
                       (eopl:pretty-print val1)
                       val1
                       )
                     )
    (block-statement (stats)
                     (let ([vals (map (lambda (stat) (result-of stat env)) stats)])
                       (last vals)
                       )
                     )
    (if-statement (exp1 consequent alternate)
                  (let ([val1 (value-of-exp exp1 env)])
                    (if (expval->bool val1)
                        (result-of consequent env)
                        (result-of alternate env)
                        )
                    )
                  )
    (while-statement (exp1 body)
                     (let loop ()
                       (let ([val (value-of-exp exp1 env)])
                         (if (expval->bool val)
                             (begin
                               (result-of body env)
                               (loop)
                               )
                             (null-val)
                             )
                         )
                       )
                     )
    (do-while-statement (exp1 body)
                        (let loop ()
                          (result-of body env)
                          (let ([val (value-of-exp exp1 env)])
                            (if (expval->bool val)
                                (loop)
                                (null-val)
                                )
                            )
                          )
                        )
    (var-statement (vars body)
                   (result-of body
                              (extend-env*
                               (map get-var-declaration-name vars)
                               (map (lambda (var) (newref (value-of-exp (get-var-declaration-exp var) env))) vars)
                               env))
                   )
    (read-statement (var)
                    (let* ([val (read-from-stdin)] [num (string->number val)])
                      (setref! (apply-env env var) (num-val num))
                      (num-val num)
                      )
                    )
    )
  )

; fake implementation for easy test
(define (read-from-stdin)
  "1"
  )

(define (value-of-exp exp env)
  (cases expression exp
    (const-exp (num) (num-val num))
    (var-exp (var)
             (let ([val (deref (apply-env env var))])
               (if (is-uninitialized? val)
                   (eopl:error 'value-of-exp "Cannot use uninitialized var ~s before initialization." var)
                   val
                   )
               )
             )
    (diff-exp (exp1 exp2)
              (let ([val1 (value-of-exp exp1 env)]
                    [val2 (value-of-exp exp2 env)])
                (let ((num1 (expval->num val1))
                      (num2 (expval->num val2)))
                  (num-val (- num1 num2))
                  )
                )
              )
    (sum-exp (exp1 exp2)
             (let ([val1 (value-of-exp exp1 env)]
                   [val2 (value-of-exp exp2 env)])
               (let ((num1 (expval->num val1))
                     (num2 (expval->num val2)))
                 (num-val (+ num1 num2))
                 )
               )
             )
    (mul-exp (exp1 exp2)
             (let ([val1 (value-of-exp exp1 env)]
                   [val2 (value-of-exp exp2 env)])
               (let ((num1 (expval->num val1))
                     (num2 (expval->num val2)))
                 (num-val (* num1 num2))
                 )
               )
             )
    (zero?-exp (exp1)
               (let ([val (value-of-exp exp1 env)])
                 (let ([num (expval->num val)])
                   (if (zero? num)
                       (bool-val #t)
                       (bool-val #f)
                       )
                   )
                 )
               )
    (not-exp (exp1)
             (let ([val (value-of-exp exp1 env)])
               (let ([bool (expval->bool val)])
                 (if bool
                     (bool-val #f)
                     (bool-val #t)
                     )
                 )
               )
             )
    (proc-exp (vars body)
              (proc-val (procedure vars body env))
              )
    (call-exp (rator rands)
              (let ((rator-val (value-of-exp rator env)) (rand-vals (value-of-exps rands env)))
                (let ((proc1 (expval->proc rator-val)))
                  (apply-procedure proc1 rand-vals)
                  )
                )
              )
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )

(define (value-of-exps exps env)
  (map (lambda (exp) (value-of-exp exp env)) exps)
  )
