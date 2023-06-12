#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-nameless-env
                     apply-nameless-env
                     extend-nameless-env
                     )]
 ["value.rkt" (num-val
               expval->num
               bool-val
               expval->bool
               proc-val
               expval->proc
               ; new stuff
               null-val
               cell-val
               cell-val?
               cell-val->first
               cell-val->second
               null-val?
               )]
 ["procedure.rkt" (procedure apply-procedure)]
 ["translator.rkt" (translation-of-program)]
 )

(provide (all-defined-out))

(define (run str)
  (let ([translated-prog (translation-of-program (scan&parse str))])
    (value-of-program translated-prog)
    )
  )

(define (value-of-program prog)
  (cases program prog
    (a-program (exp1) (value-of-exp exp1 (init-nameless-env)))
    )
  )

(define (value-of-exp exp env)
  (cases expression exp
    (const-exp (num) (num-val num))
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
    (call-exp (rator rand)
              (let ([rator-val (value-of-exp rator env)] [rand-val (value-of-exp rand env)])
                (let ((proc1 (expval->proc rator-val)))
                  (apply-procedure proc1 rand-val)
                  )
                )
              )

    ; new suff
    (cons-exp (exp1 exp2)
              (let ([val1 (value-of-exp exp1 env)] [val2 (value-of-exp exp2 env)])
                (cell-val val1 val2)
                )
              )
    (car-exp (exp1)
             (let ([val1 (value-of-exp exp1 env)])
               (cell-val->first val1)
               )
             )
    (cdr-exp (exp1)
             (let ([val1 (value-of-exp exp1 env)])
               (cell-val->second val1)
               )
             )
    (emptylist-exp () (null-val))
    (null?-exp (exp1)
               (let ([val1 (value-of-exp exp1 env)])
                 (bool-val (null-val? val1))
                 )
               )

    ; new stuff
    (nameless-var-exp (num) (apply-nameless-env env num))
    (nameless-let-exp (exp1 body)
                      (let ([val (value-of-exp exp1 env)])
                        (value-of-exp body (extend-nameless-env val env))
                        )
                      )
    (nameless-proc-exp (body)
                       (proc-val (procedure body env))
                       )
    ; new stuff
    (nameless-unpack-exp (exp1 body)
                         (let ([val1 (value-of-exp exp1 env)])
                           (value-of-exp body (extend-env-unpack val1 env))
                           )
                         )
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )

; new stuff
(define (extend-env-unpack val env)
  (cond
    ((null-val? val) env)
    ((cell-val? val)
     (let ((first-val (cell-val->first val)))
       ; define vars from left to right
       (let ((new-env (extend-nameless-env first-val env)))
         (extend-env-unpack (cell-val->second val) new-env)
         )
       )
     )
    )
  )
