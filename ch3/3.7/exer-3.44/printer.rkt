#lang eopl

(require "expression.rkt")

(provide (all-defined-out))

(define (print-program prog)
  (cases program prog
    (a-program (exp1)
               (print-exp exp1)
               )
    )
  )

(define (print-exp exp)
  (cases expression exp
    (const-exp (num) (number->string num))
    (diff-exp (exp1 exp2)
              (string-append
               "-("
               (print-exp exp1)
               ", "
               (print-exp exp2)
               ")"
               )
              )
    (zero?-exp (exp1)
               (string-append
                "zero?("
                (print-exp exp1)
                ")"
                )
               )
    (if-exp (exp1 exp2 exp3)
            (string-append
             "if "
             (print-exp exp1)
             " then "
             (print-exp exp2)
             " else "
             (print-exp exp3)
             )
            )
    (var-exp (var) (symbol->string var))
    (let-exp (var exp1 body)
             (string-append
              "let "
              (symbol->string var)
              " = "
              (print-exp exp1)
              " in "
              (print-exp body)
              )
             )
    (proc-exp (var body)
              (string-append "proc (" (symbol->string var) ") " (print-exp body))
              )
    (call-exp (rator rand)
              (string-append "(" (print-exp rator) " " (print-exp rand) ")")
              )
    (nameless-var-exp (num) (string-append "%lexref " (number->string num)))
    (nameless-let-exp (exp1 body) (string-append "%let " (print-exp exp1) " in " (print-exp body)))
    (nameless-proc-exp (body) (string-append "%lexproc " (print-exp body)))
    (else (eopl:error 'translation-of-exp "unsupported expression type ~s" exp))
    )
  )
