#lang eopl

(require "cps-lang/expression.rkt")

(define (tail-form? prog)
  (cases program prog
    (a-program (exp) (tail-form-exp? exp))
    )
  )

(define (tail-form-exp? exp1)
  (cases expression exp1
    (const-exp (num) #t)
    (diff-exp (exp1 exp2)
              (and (tail-form-operand-position? exp1) (tail-form-operand-position? exp2))
              )
    (zero?-exp (exp1) (tail-form-operand-position? exp1))
    (if-exp (exp1 exp2 exp3)
            (and
             (tail-form-operand-position? exp1)
             (tail-form-tail-position? exp2)
             (tail-form-tail-position? exp3)
             )
            )
    (var-exp (var) #t)
    (let-exp (var exp1 body)
             (and
              (tail-form-operand-position? exp1)
              (tail-form-tail-position? body)
              )
             )
    (letrec-exp (p-names b-vars p-bodies body)
                (all tail-form-tail-position? (append p-bodies (list body)))
                )
    (proc-exp (vars body) (tail-form-tail-position? body))
    (call-exp (rator rands)
              (all tail-form-operand-position? (cons rator rands))
              )
    (sum-exp (exps) (all tail-form-operand-position? exps))
    (else (eopl:error 'tail-form-exp? "unsupported expression ~s " exp1))
    )
  )

(define (tail-form-operand-position? exp1)
  (cases expression exp1
    (call-exp (rator rands) #f)
    (else (tail-form-exp? exp1))
    )
  )

(define (tail-form-tail-position? exp1)
  (tail-form-exp? exp1)
  )

(define (all pred lst)
  (if (null? lst)
      #t
      (let ((first (car lst)) (rest (cdr lst)))
        (if (pred first)
            (all pred rest)
            #f
            )
        )
      )
  )
