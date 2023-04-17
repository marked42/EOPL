#lang eopl

(require racket/lazy-require "basic.rkt" "value.rkt" "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env
                     extend-mul-env
                     build-circular-extend-env-rec-mul-vec
                     environment?
                     )]
 ["procedure.rkt" (apply-procedure procedure)])

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )


(define-datatype continuation cont?
  (end-cont)
  (diff-cont-1 (saved-cont cont?) (exp2 expression?) (saved-env environment?))
  (diff-cont-2 (saved-cont cont?) (val1 expval?))
  (zero?-cont (saved-cont cont?))
  (if-cont (saved-cont cont?) (exp2 expression?) (exp3 expression?) (saved-env environment?))
  (exps-cont (saved-cont cont?) (exps (list-of expression?)) (vals (list-of expval?)) (saved-env environment?))
  (let-cont (saved-cont cont?) (vars (list-of identifier?)) (body expression?) (env environment?))
  (call-exp-cont (saved-cont cont?))
  )

(define (apply-cont cont val)
  (cases continuation cont
    (end-cont ()
              (eopl:printf "End of computation.~%")
              val
              )
    (diff-cont-1 (saved-cont exp2 saved-env)
                 (value-of/k exp2 saved-env (diff-cont-2 saved-cont val))
                 )
    (diff-cont-2 (saved-cont val1)
                 (apply-cont saved-cont
                             (let ((num1 (expval->num val1)) (num2 (expval->num val)))
                               (num-val (- num1 num2))
                               )
                             )
                 )
    (zero?-cont (saved-cont)
                (let ((num (expval->num val)))
                  (apply-cont saved-cont
                              (if (zero? num)
                                  (bool-val #t)
                                  (bool-val #f)
                                  )
                              )
                  )
                )
    (if-cont (saved-cont exp2 exp3 saved-env)
             (let ((exp (if (expval->bool val) exp2 exp3)))
               (value-of/k exp saved-env saved-cont)
               )
             )
    (exps-cont (saved-cont exps vals env)
               (value-of-exps/k exps (append vals (list val)) env saved-cont)
               )
    (let-cont (saved-cont vars body env)
              (let ((vals val))
                (value-of/k body (extend-mul-env vars vals env) saved-cont)
                )
              )
    (call-exp-cont (saved-cont)
                   (let ((rator-val (car val)) (rand-vals (cdr val)))
                     (let ((proc1 (expval->proc rator-val)))
                       (apply-procedure proc1 rand-vals saved-cont)
                       )
                     )
                   )
    )
  )

(define (value-of-program prog)
  (cases program prog
    (a-program (exp1) (value-of/k exp1 (init-env) (end-cont)))
    )
  )

(define (value-of-exps/k exps vals env saved-cont)
  (if (null? exps)
      (apply-cont saved-cont vals)
      (let ((first-exp (car exps)) (rest-exps (cdr exps)))
        (value-of/k
         first-exp
         env
         (exps-cont saved-cont rest-exps vals env)
         )
        )
      )
  )

; TODO: better always place cont at first
(define (value-of/k exp env cont)
  (cases expression exp
    (const-exp (num) (apply-cont cont (num-val num)))
    (diff-exp (exp1 exp2)
              (value-of/k exp1 env (diff-cont-1 cont exp2 env))
              )
    (zero?-exp (exp1)
               (value-of/k exp1 env (zero?-cont cont))
               )
    (if-exp (exp1 exp2 exp3)
            (value-of/k exp1 env (if-cont cont exp2 exp3 env))
            )
    (var-exp (var)
             (apply-cont cont (apply-env env var))
             )
    (let-exp (vars exps body)
             (value-of-exps/k exps '() env (let-cont cont vars body env))
             )
    (proc-exp (first-var rest-vars body)
              (apply-cont cont (proc-val (procedure (cons first-var rest-vars) body env)))
              )
    (call-exp (rator rands)
              (value-of-exps/k (cons rator rands) '() env (call-exp-cont cont))
              )
    (letrec-exp (p-names b-vars-list p-bodies body)
                (let ((new-env (build-circular-extend-env-rec-mul-vec p-names b-vars-list p-bodies env)))
                  (value-of/k body new-env cont)
                  )
                )
    (else (eopl:error "invalid exp ~s" exp))
    )
  )

(define (report-cond-no-true-predicate exp)
  (eopl:error 'cond-exp "No true cond for exp ~s" exp)
  )

(define (report-cond-invalid-predicate exp)
  (eopl:error 'cond-exp "invalid predicate " exp)
  )
