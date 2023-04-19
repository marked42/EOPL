#lang eopl

(require racket/lazy-require "basic.rkt" "value.rkt" "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-mul-env
                     build-circular-extend-env-rec-mul-vec
                     environment?
                     )]
 ["store.rkt" (deref initialize-store! vals->refs setref reference?)]
 ["procedure.rkt" (apply-procedure/k procedure)])

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (end-cont) (lambda (val) val))

(define (apply-cont cont val)
  (cont val)
  )

; (define-datatype continuation cont?
;   (end-cont)
;   (call-exp-cont (saved-cont cont?) (rands (list-of expression?)) (saved-env environment?))
;   (call-exp-cont-2 (saved-cont cont?) (rator expval?))
;   (operands-cont (saved-cont cont?) (exps (list-of expression?)) (vals (list-of expval?)) (saved-env environment?))

;   (null?-exp-cont (saved-cont cont?))
;   (car-exp-cont (saved-cont cont?))
;   (cdr-exp-cont (saved-cont cont?))
;   (list-exp-cont (saved-cont cont?))

;   (begin-operands-cont (saved-cont cont?) (exps (list-of expression?)) (last-val expval?) (saved-env environment?))

;   (set-rhs-cont (ref reference?) (saved-cont cont?))
;   )

; (define (apply-cont cont val)
;   (cases continuation cont
;     (end-cont () val)
;     (call-exp-cont (saved-cont rands saved-env)
;                    (let ((rator val))
;                      (value-of-operands/k rands '() saved-env (call-exp-cont-2 saved-cont rator))
;                      )
;                    )
;     (call-exp-cont-2 (saved-cont rator)
;                      (let ((proc1 (expval->proc rator)) (rands val))
;                        (apply-procedure/k proc1 rands saved-cont)
;                        )
;                      )
;     (operands-cont (saved-cont exps vals env)
;                    (value-of-operands/k exps (append vals (list val)) env saved-cont)
;                    )
;     (null?-exp-cont (saved-cont)
;                     (let ((res
;                            (cases expval val
;                              (null-val () (bool-val #t))
;                              (else (bool-val #f))
;                              )
;                            ))
;                       (apply-cont saved-cont res)
;                       )
;                     )
;     (car-exp-cont (saved-cont)
;                   (let ((res (cell-val->first val)))
;                     (apply-cont saved-cont res)
;                     )
;                   )
;     (cdr-exp-cont (saved-cont)
;                   (let ((res (cell-val->second val)))
;                     (apply-cont saved-cont res)
;                     )
;                   )
;     (list-exp-cont (saved-cont)
;                    (apply-cont saved-cont (build-list-from-vals val))
;                    )

;     (begin-operands-cont (saved-cont exps last-val saved-env)
;                          (value-of-begin-operands/k exps val saved-env saved-cont)
;                          )
;     (set-rhs-cont (ref saved-cont)
;                   (setref ref val)
;                   (apply-cont saved-cont val)
;                   )
;     )
;   )


; (define (build-list-from-vals vals)
;   (if (null? vals)
;       (null-val)
;       (let ((first (car vals)) (rest (cdr vals)))
;         (cell-val first (build-list-from-vals rest))
;         )
;       )
;   )

; (define (value-of-operands/k exps vals env saved-cont)
;   (if (null? exps)
;       (apply-cont saved-cont vals)
;       (let ((first-exp (car exps)) (rest-exps (cdr exps)))
;         (cases expression first-exp
;           (var-exp (var)
;                    (let ((val (deref (apply-env env var))))
;                      (value-of-operands/k rest-exps (append vals (list val)) env saved-cont)
;                      )
;                    )
;           (else
;            (value-of/k first-exp env
;                        (operands-cont saved-cont rest-exps vals env)
;                        )
;            )
;           )
;         )
;       )
;   )

(define (value-of-program prog)
  (initialize-store!)
  (cases program prog
    (a-program (exp1) (value-of/k exp1 (init-env) (end-cont)))
    )
  )

; (define (value-of-begin-operands/k exps last-val env saved-cont)
;   (if (null? exps)
;       (apply-cont saved-cont last-val)
;       (let ((first-exp (car exps)) (rest-exps (cdr exps)))
;         (value-of/k
;          first-exp
;          env
;          (begin-operands-cont saved-cont rest-exps last-val env)
;          )
;         )
;       )
;   )

(define (eval-diff-exp val1 val2)
  (let ((num1 (expval->num val1)) (num2 (expval->num val2)))
    (num-val (- num1 num2))
    )
  )

(define (diff-cont saved-cont exp1 exp2 saved-env)
  (lambda (val)
    (value-of/k exp1 saved-env
                (lambda (val1)
                  (value-of/k exp2 saved-env
                              (lambda (val2)
                                (apply-cont saved-cont (eval-diff-exp val1 val2))
                                ))
                  )
                )
    )
  )

(define (zero?-cont saved-cont exp1 saved-env)
  (lambda (val)
    (value-of/k exp1 saved-env
                (lambda (val1)
                  (apply-cont saved-cont (eval-zero?-exp val1))
                  )
                )
    )
  )

(define (eval-zero?-exp val1)
  (let ((num (expval->num val1)))
    (if (zero? num)
        (bool-val #t)
        (bool-val #f)
        )
    )
  )

(define (if-cont saved-cont exp1 exp2 exp3 saved-env)
  (lambda (val)
    (value-of/k exp1 saved-env
                (lambda (val1)
                  (value-of/k (eval-if-exp val1 exp2 exp3) saved-env saved-cont)
                  ))
    )
  )

(define (eval-if-exp val1 exp2 exp3)
  (let ((exp (if (expval->bool val1) exp2 exp3)))
    exp
    )
  )

(define (let-cont saved-cont vars exps body saved-env)
  (lambda (val)
    (value-of-exps/k exps saved-env
                     (lambda (vals)
                       (value-of/k body (extend-mul-env vars (vals->refs vals) saved-env) saved-cont)
                       )
                     )
    )
  )

(define (value-of-exps-helper/k exps vals saved-env saved-cont)
  (if (null? exps)
      (apply-cont saved-cont vals)
      (let ((first-exp (car exps)) (rest-exps (cdr exps)))
        (value-of/k
         first-exp
         saved-env
         (lambda (val)
           (value-of-exps-helper/k rest-exps (append vals (list val)) saved-env saved-cont)
           )
         )
        )
      )
  )

(define (value-of-exps/k exps saved-env saved-cont)
  (value-of-exps-helper/k exps '() saved-env saved-cont)
  )

(define (value-of/k exp env cont)
  (cases expression exp
    (const-exp (num) (apply-cont cont (num-val num)))
    (diff-exp (exp1 exp2)
              (apply-cont (diff-cont cont exp1 exp2 env) '())
              )
    (zero?-exp (exp1)
               (apply-cont (zero?-cont cont exp1 env) '())
               )
    (if-exp (exp1 exp2 exp3)
            (apply-cont (if-cont cont exp1 exp2 exp3 env) '())
            )
    (var-exp (var)
             (apply-cont cont (deref (apply-env env var)))
             )
    (let-exp (vars exps body)
             (apply-cont (let-cont cont vars exps body env) '())
             )
    (proc-exp (first-var rest-vars body)
              (apply-cont cont (proc-val (procedure (cons first-var rest-vars) body env)))
              )
    (call-exp (rator rands)
              (apply-cont (call-exp-cont cont rator rands env) '())
              )
    (letrec-exp (p-names b-vars-list p-bodies body)
                (apply-cont (letrec-exp-cont cont p-names b-vars-list p-bodies body env) '())
                )
    ; list
    (emptylist-exp () (apply-cont cont (null-val)))
    (cons-exp (exp1 exp2)
              (apply-cont (cons-exp-cont cont exp1 exp2 env) '())
              )
    ; (null?-exp (exp1)
    ;            (value-of/k exp1 env (null?-exp-cont cont))
    ;            )
    ; (car-exp (exp1)
    ;          (value-of/k exp1 env (car-exp-cont cont))
    ;          )
    ; (cdr-exp (exp1)
    ;          (value-of/k exp1 env (cdr-exp-cont cont))
    ;          )
    ; (list-exp (exp1 exps)
    ;           (value-of-exps/k (cons exp1 exps) '() env (list-exp-cont cont))
    ;           )
    ; (begin-exp (exp1 exps)
    ;            (value-of-begin-operands/k (cons exp1 exps) (bool-val #f) env cont)
    ;            )
    ; (assign-exp (var exp1)
    ;             (value-of/k exp1 env (set-rhs-cont (apply-env env var) cont))
    ;             )
    (else (eopl:error "invalid exp ~s" exp))
    )
  )

(define (call-exp-cont saved-cont rator rands saved-env)
  (lambda (val)
    (value-of/k rator saved-env
                (lambda (rator)
                  (value-of-exps/k rands saved-env
                                   (lambda (args)
                                     (let ((proc1 (expval->proc rator)))
                                       (apply-procedure/k proc1 args saved-cont)
                                       )
                                     )
                                   )
                  )
                )
    )
  )

(define (letrec-exp-cont saved-cont p-names b-vars-list p-bodies body saved-env)
  (lambda (val)
    (let ((new-env (build-circular-extend-env-rec-mul-vec p-names b-vars-list p-bodies saved-env)))
      (value-of/k body new-env saved-cont)
      )
    )
  )

(define (cons-exp-cont saved-cont exp1 exp2 saved-env)
  (lambda (val)
    (value-of/k exp1 saved-env
                (lambda (val1)
                  (value-of/k exp2 saved-env
                              (lambda (val2)
                                (apply-cont saved-cont (eval-cons-exp val1 val2))
                                )
                              )
                  )
                )
    )
  )

(define (eval-cons-exp val1 val2)
  (cell-val val1 val2)
  )
