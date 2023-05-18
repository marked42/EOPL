#lang eopl

(define (value-of-const-or-var-exp exp env)
  (cases simple-expression exp1
    (cps-const-exp (num) (num-val num))
    (cps-var-exp (var) (apply-env env var))
    (else (eopl:error 'value-of-const-or-var-exp "unsupported simple-expression ~s " exp1))
    )
  )
(define (value-of-simple-exp exp1 env)
  (cases simple-expression exp1
    (cps-const-exp (num) (value-of-const-or-var-exp exp1 env))
    (cps-var-exp (var) (value-of-const-or-var-exp exp1 env))
    (cps-diff-exp (exp1 exp2)
                  (let ((val1 (value-of-const-or-var-exp exp1 env))
                        (val2 (value-of-const-or-var-exp exp2 env)))
                    (let ((num1 (expval->num val1))
                          (num2 (expval->num val2)))
                      (num-val (- num1 num2))
                      )
                    )
                  )
    ; true only if exp1 is number 0
    (cps-zero?-exp (exp1)
                   (let ((val (value-of-const-or-var-exp exp1 env)))
                     (let ((num (expval->num val)))
                       (if (zero? num)
                           (bool-val #t)
                           (bool-val #f)
                           )
                       )
                     )
                   )
    (cps-proc-exp (vars body)
                  (proc-val (procedure vars body env))
                  )
    (cps-sum-exp (exps)
                 (let ((nums (map
                              (lambda (exp)
                                (expval->num
                                 (value-of-const-or-var-exp exp env)))
                              exps)))
                   (num-val
                    (let sum-loop ((nums nums))
                      (if (null? nums) 0
                          (+ (car nums) (sum-loop (cdr nums))))))))
    (else (eopl:error 'value-of-simple-exp "unsupported simple-expression ~s " exp1))
    )
  )
