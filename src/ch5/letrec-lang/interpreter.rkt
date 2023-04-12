#lang eopl

(require racket/lazy-require "value.rkt" "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env
                     extend-mul-env
                     build-circular-extend-env-rec-mul-vec
                     environment?
                     )]
 ["procedure.rkt" (apply-procedure procedure trace-procedure)])

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
  )
)

(define (value-of-program prog)
  (cases program prog
    (a-program (exp1) (value-of/k exp1 (init-env) (end-cont)))
    )
  )

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
    (else (eopl:error "invalid exp ~s" exp))
  )
)

; get value of a list of exp
; (define (value-of-exps exps env)
;   (map (lambda (exp) (value-of-exp exp env)) exps)
;   )

; (define (value-of-exp exp env)
;   (cases expression exp
;     ; number constant
;     (const-exp (num) (num-val num))
;     ; subtraction of two numbers
;     (diff-exp (exp1 exp2)
;               (let ((val1 (value-of-exp exp1 env))
;                     (val2 (value-of-exp exp2 env)))
;                 (let ((num1 (expval->num val1))
;                       (num2 (expval->num val2)))
;                   (num-val (- num1 num2))
;                   )
;                 )
;               )
;     ; true only if exp1 is number 0
;     (zero?-exp (exp1)
;                (let ((val (value-of-exp exp1 env)))
;                  (let ((num (expval->num val)))
;                    (if (zero? num)
;                        (bool-val #t)
;                        (bool-val #f)
;                        )
;                    )
;                  )
;                )
;     (if-exp (exp1 exp2 exp3)
;             (let ((val1 (value-of-exp exp1 env)))
;               (if (expval->bool val1)
;                   (value-of-exp exp2 env)
;                   (value-of-exp exp3 env)
;                   )
;               )
;             )
;     (var-exp (var)
;              (apply-env env var)
;              )
;     (let-exp (vars exps body)
;              (let ((vals (value-of-exps exps env)))
;                (value-of-exp body (extend-mul-env vars vals env))
;                )
;              )
;     (letrec-exp (p-names b-vars-list p-bodies body)
;                 (let ((new-env (build-circular-extend-env-rec-mul-vec p-names b-vars-list p-bodies env)))
;                   (value-of-exp body new-env)
;                   )
;                 )
;     (proc-exp (first-var rest-vars body)
;               (proc-val (procedure (cons first-var rest-vars) body env))
;               )
;     (call-exp (rator rands)
;               (let ((rator-val (value-of-exp rator env)) (rand-vals (value-of-exps rands env)))
;                 (let ((proc1 (expval->proc rator-val)))
;                   (apply-procedure proc1 rand-vals)
;                   )
;                 )
;               )
;     (else 42)
;     )
;   )

(define (report-cond-no-true-predicate exp)
  (eopl:error 'cond-exp "No true cond for exp ~s" exp)
  )

(define (report-cond-invalid-predicate exp)
  (eopl:error 'cond-exp "invalid predicate " exp)
  )
