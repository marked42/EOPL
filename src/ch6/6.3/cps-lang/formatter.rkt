#lang eopl

(require racket/lazy-require racket/list racket/string "expression.rkt")

(provide (all-defined-out))

(define (format-cps-program cps-prog)
  (cases cps-program cps-prog
    (cps-a-program (exp1)
                   (format-cps-exp exp1)
                   )
    )
  )

(define (format-cps-exp exp)
  (cases tfexp exp
    (simple-exp->exp (exp1)
                     (format-simple-exp exp1)
                     )
    (cps-let-exp (var exp1 body)
                 (string-append
                  "let "
                  (symbol->string var)
                  " = "
                  (format-simple-exp exp1)
                  " in "
                  (format-cps-exp body)
                  )
                 )
    (cps-letrec-exp (p-names b-varss p-bodies body)
                    (string-append
                     "letrec "
                     (string-join (map format-letrec-proc p-names b-varss p-bodies) " ")
                     " in "
                     (format-cps-exp body)
                     )
                    )
    (cps-if-exp (exp1 exp2 exp3)
                (string-append
                 "if "
                 (format-simple-exp exp1)
                 " then "
                 (format-cps-exp exp2)
                 " else "
                 (format-cps-exp exp3)
                 )
                )
    (cps-call-exp (rator rands)
                  (string-append
                   "("
                   (string-join (map format-simple-exp (cons rator rands)) " ")
                   ")"
                   )
                  )
    (else (eopl:error 'format-cps-exp "invalid expression ~s " exp))
    )
  )

(define (format-letrec-proc p-name b-vars p-body)
  (string-append
   (symbol->string p-name)
   "("
   (string-join (map symbol->string b-vars) ", ")
   ") = "
   (format-cps-exp p-body)
   )
  )

(define (format-simple-exp simple-exp)
  (cases simple-expression simple-exp
    (cps-const-exp (num) (number->string num))
    (cps-var-exp (var) (symbol->string var))
    (cps-diff-exp (exp1 exp2)
                  (string-append
                   "-("
                   (format-simple-exp exp1)
                   ", "
                   (format-simple-exp exp2)
                   ")"
                   )
                  )
    (cps-zero?-exp (exp1)
                   (string-append
                    "zero?(" (format-simple-exp exp1) ")"
                    )
                   )
    (cps-proc-exp (vars body)
                  (string-append "proc (" (string-join (map symbol->string vars) ", ") ") " (format-cps-exp body))
                  )
    (cps-sum-exp (exps)
                 (string-append
                  "+("
                  (string-join (map format-simple-exp exps) ", ")
                  ")"
                  )
                 )
    (cps-list-exp (exps)
                 (string-append
                  "list("
                  (string-join (map format-simple-exp exps) ", ")
                  ")"
                  )
                 )
    (else (eopl:error 'format-simple-exp "invalid expression ~s " exp))
    )
  )
