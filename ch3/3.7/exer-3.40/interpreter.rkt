#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt" "procedure.rkt")
(lazy-require
 ["environment.rkt" (
                     init-nameless-env
                     apply-nameless-env
                     extend-nameless-env
                     )]
 ["value.rkt" (num-val expval->num bool-val expval->bool proc-val expval->proc)]
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
    (nameless-letrec-exp (p-body body)
                         (let ([the-proc (proc-val (procedure p-body env))])
                          (value-of-exp body (extend-nameless-env the-proc env))
                          )
                         )
    (nameless-letrec-var-exp (num)
                             ; list-tail find tail part of list starting from target element
                             (let ([new-nameless-env (list-tail env num)])
                              ; so car of new-nameless-env is the-proc corresponding to letrec-var
                              (let ([the-proc (expval->proc (car new-nameless-env))])
                                ; cases requires to "procedure.rkt" to load eagerly
                                (cases proc the-proc
                                  (procedure (body saved-env)
                                    ; environment of procedure body is new-nameless-env with first var being
                                    ; the-proc itself
                                    (proc-val (procedure body new-nameless-env))
                                    )
                                  (else (eopl:error 'value-of-exp "expect a procedure, got ~s" the-proc))
                                  )
                                )
                              )
                             )
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )
