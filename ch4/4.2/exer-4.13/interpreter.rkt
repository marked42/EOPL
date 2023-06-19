#lang eopl

(require racket/lazy-require racket/list "parser.rkt" "expression.rkt" "answer.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env*
                     extend-env-rec
                     )]
 ["value.rkt" (num-val expval->num bool-val expval->bool proc-val expval->proc ref-val expval->ref)]
 ["procedure.rkt" (procedure apply-procedure)]
 ["store.rkt" (newref deref setref! empty-store)]
 )

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  (cases program prog
    (a-program (exp1)
               (let ([ans (value-of-exp exp1 (init-env) (empty-store))])
                 (cases answer ans
                   (an-answer (val store) val)
                   )
                 )
               )
    )
  )

(define (value-of-exp exp env store)
  (cases expression exp
    (const-exp (num) (an-answer (num-val num) store))
    (var-exp (var) (an-answer (apply-env env var) store))
    (diff-exp (exp1 exp2)
              (let* ([lst (value-of-exp1-exp2 exp1 exp2 env store)] [val1 (first lst)] [val2 (second lst)] [new-store (third lst)])
                (let ((num1 (expval->num val1))
                      (num2 (expval->num val2)))
                  (an-answer (num-val (- num1 num2)) new-store)
                  )
                )
              )
    (zero?-exp (exp1)
               (let ([ans (value-of-exp exp1 env store)])
                 (cases answer ans
                   (an-answer (val new-store)
                              (let ([num (expval->num val)])
                                (an-answer
                                 (if (zero? num)
                                     (bool-val #t)
                                     (bool-val #f)
                                     )
                                 new-store)
                                )
                              )
                   )
                 )
               )
    (if-exp (exp1 exp2 exp3)
            (let ([ans1 (value-of-exp exp1 env store)])
              (cases answer ans1
                (an-answer (val1 new-store)
                           (if (expval->bool val1)
                               (value-of-exp exp2 env new-store)
                               (value-of-exp exp3 env new-store)
                               )
                           )
                )
              )
            )
    (let-exp (var exp1 body)
             (let ([ans (value-of-exp exp1 env store)])
               (cases answer ans
                 (an-answer (val store)
                            (value-of-exp body (extend-env* (list var) (list val) env) store)
                            )
                 )
               )
             )
    (proc-exp (vars body)
              (an-answer (proc-val (procedure vars body env)) store)
              )
    (call-exp (rator rands)
              (let* ([ans (value-of-exps (cons rator rands) env store)] [vals (car ans)] [new-store (cdr ans)] [rator-val (car vals)] [rand-vals (cdr vals)])
                (let ((proc1 (expval->proc rator-val)))
                  (apply-procedure proc1 rand-vals new-store)
                  )
                )
              )
    (letrec-exp (p-name b-var p-body body)
                (let ((new-env (extend-env-rec p-name b-var p-body env)))
                  (value-of-exp body new-env store)
                  )
                )

    ; new stuff
    (newref-exp (exp1)
                (let ([ans (value-of-exp exp1 env store)])
                  (cases answer ans
                    (an-answer (val store)
                               (let* ([pair (newref store val)] [new-store (car pair)] [ref (cdr pair)])
                                 (an-answer (ref-val ref) new-store)
                                 )
                               )
                    )
                  )
                )
    (deref-exp (exp1)
               (let ([ans (value-of-exp exp1 env store)])
                 (cases answer ans
                   (an-answer (val store)
                              (let* ([pair (deref store (expval->ref val))] [new-store (car pair)] [val (cdr pair)])
                                (an-answer val new-store)
                                )
                              )
                   )
                 )
               )
    (setref-exp (exp1 exp2)
                (let* ([lst (value-of-exp1-exp2 exp1 exp2 env store)] [val1 (first lst)] [val2 (second lst)] [new-store (third lst)])
                  (let* ([ref1 (expval->ref val1)] [pair (setref! new-store ref1 val2)] [new-store (car pair)] [val (cdr pair)])
                    (an-answer val new-store)
                    )
                  )
                )
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )

(define (value-of-exp1-exp2 exp1 exp2 env store)
  (let ([ans1 (value-of-exp exp1 env store)])
    (cases answer ans1
      (an-answer (val1 store1)
                 (let ([ans2 (value-of-exp exp2 env store1)])
                   (cases answer ans2
                     (an-answer (val2 store2)
                                (list val1 val2 store2)
                                )
                     )
                   )
                 )
      )
    )
  )

(define (value-of-exps exps env store)
  (let loop ([vals '()] [exps exps] [store store])
    (if (null? exps)
        (cons vals store)
        (let ([ans (value-of-exp (car exps) env store)])
          (cases answer ans
            (an-answer (val new-store)
                       (loop (append vals (list val)) (cdr exps) new-store)
                       )
            )
          )
        )
    )
  )
