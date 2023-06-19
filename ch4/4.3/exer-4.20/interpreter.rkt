#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env
                     extend-env-rec*
                     )]
 ["value.rkt" (num-val expval->num bool-val expval->bool proc-val expval->proc)]
 ["procedure.rkt" (procedure apply-procedure)]
 ["store.rkt" (initialize-store! newref deref setref! reference?)]
 )

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  ; new stuff
  (initialize-store!)
  (cases program prog
    (a-program (exp1) (value-of-exp exp1 (init-env)))
    )
  )

(define (value-of-exp exp env)
  (cases expression exp
    (const-exp (num) (num-val num))
    ; new stuff
    (var-exp (var) (let ([ref-or-val (apply-env env var)])
                    (if (reference? ref-or-val)
                      (deref ref-or-val)
                      ref-or-val
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
    (if-exp (exp1 exp2 exp3)
            (let ([val1 (value-of-exp exp1 env)])
              (if (expval->bool val1)
                  (value-of-exp exp2 env)
                  (value-of-exp exp3 env)
                  )
              )
            )
    (let-exp (var exp1 body)
             (let ([val (value-of-exp exp1 env)])
               (value-of-exp body (extend-env var val env))
               )
             )
    (letmutable-exp (var exp1 body)
             (let ([val (value-of-exp exp1 env)])
               ; new stuff
               (value-of-exp body (extend-env var (newref val) env))
               )
             )
    (proc-exp (var body)
              (proc-val (procedure var body env))
              )
    (call-exp (rator rand)
              (let ((rator-val (value-of-exp rator env)) (rand-val (value-of-exp rand env)))
                (let ((proc1 (expval->proc rator-val)))
                  (apply-procedure proc1 rand-val)
                  )
                )
              )
    (letrec-exp (p-names b-vars p-bodies body)
                (let ((new-env (extend-env-rec* p-names b-vars p-bodies env)))
                  (value-of-exp body new-env)
                  )
                )
    (begin-exp (exp1 exps)
               (let value-of-begin-exps ([exps (cons exp1 exps)])
                 (if (null? exps)
                     (eopl:error 'value-of-exp "begin expression should have at lease one expression")
                     (let ((first-exp (car exps)) (rest-exps (cdr exps)))
                       ; always calculate first exp cause it may has side effects
                       (let ((first-val (value-of-exp first-exp env)))
                         (if (null? rest-exps)
                             first-val
                             (value-of-begin-exps rest-exps)
                             )
                         )
                       )
                     )
                 )
               )
    ; new stuff
    (assign-exp (var exp1)
                (let ([val1 (value-of-exp exp1 env)] [ref-or-val (apply-env env var)])
                  (if (reference? ref-or-val)
                    (setref! ref-or-val val1)
                    (eopl:error 'value-of-exp "Cannot assign expression ~s to immutable variable ~s" exp1 var)
                    )
                  )
                )
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )
