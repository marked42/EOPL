#lang eopl

(provide (all-defined-out))

(define-datatype expression expression?
  (const-exp (num number?))
  (var-exp (var symbol?))
  (diff-exp (exp1 expression?) (exp2 expression?))
  (sum-exp (exp1 expression?) (exp2 expression?))
  (mul-exp (exp1 expression?) (exp2 expression?))
  (if-exp (exp1 expression?) (exp2 expression?) (exp3 expression?))
  (zero?-exp (exp1 expression?))
  (not-exp (exp1 expression?))
  (proc-exp (vars (list-of symbol?)) (body expression?))
  (call-exp (rator expression?) (rands (list-of expression?)))
  )

(define-datatype program program?
  (a-program
   (body statement?)
   )
  )

(define-datatype statement statement?
  (assign-statement (var symbol?) (exp1 expression?))
  (print-statement (exp1 expression?))
  (block-statement (stat1 (list-of statement?)))
  (if-statement (exp1 expression?) (consequent statement?) (alternate statement?))
  (while-statement (exp1 expression?) (body statement?))
  (do-while-statement (exp1 expression?) (body statement?))
  (var-statement (vars (list-of var-declaration?)) (body statement?))
  (varrec-statement (p-names (list-of symbol?)) (b-vars (list-of symbol?)) (p-bodies (list-of expression?)) (body statement?))
  (read-statement (var symbol?))
  )

(define-datatype var-declaration var-declaration?
  (a-var-decl (name symbol?) (exp1 expression?))
  )


(define (get-var-declaration-name var)
  (cases var-declaration var
    (a-var-decl (var exp1)
                var
                )
    )
  )

(define (get-var-declaration-exp var)
  (cases var-declaration var
    (a-var-decl (var exp1)
                exp1
                )
    )
  )
