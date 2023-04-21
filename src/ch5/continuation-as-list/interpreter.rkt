#lang eopl

(require
  racket/lazy-require
  racket/list
  ; use program and expression datatype
  "../shared/expression.rkt"
  )
(lazy-require
 ["../shared/environment.rkt" (init-env apply-env)]
 ["../shared/store.rkt" (initialize-store!)]
 ["../shared/eval.rkt" (eval-const-exp eval-var-exp eval-proc-exp eval-letrec-exp eval-emptylist-exp)]
 ["../shared/parser.rkt" (scan&parse)]
 ["continuation.rkt" (
                      end-cont
                      build-cont
                      apply-cont
                      diff-frame-1
                      zero?-frame
                      if-frame
                      exps-frame
                      let-frame
                      call-exp-frame
                      cons-exp-frame-1
                      null?-exp-frame
                      car-exp-frame
                      cdr-exp-frame
                      list-exp-frame
                      begin-exp-frame
                      set-rhs-frame
                      )]
 )

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  (initialize-store!)
  (cases program prog
    (a-program (exp1) (value-of/k exp1 (init-env) (end-cont)))
    )
  )

(define (value-of/k exp env cont)
  (cases expression exp
    (const-exp (num) (apply-cont cont (eval-const-exp num)))
    (diff-exp (exp1 exp2)
              (value-of/k exp1 env (build-cont (diff-frame-1 exp2 env) cont))
              )
    (zero?-exp (exp1)
               (value-of/k exp1 env (build-cont (zero?-frame) cont))
               )
    (if-exp (exp1 exp2 exp3)
            (value-of/k exp1 env (build-cont (if-frame exp2 exp3 env) cont))
            )
    (var-exp (var)
             (apply-cont cont (eval-var-exp env var))
             )
    (let-exp (vars exps body)
             (value-of-exps/k exps env (build-cont (let-frame vars body env) cont))
             )
    (proc-exp (first-var rest-vars body)
              (apply-cont cont (eval-proc-exp first-var rest-vars body env))
              )
    (call-exp (rator rands)
              (value-of/k rator env (build-cont (call-exp-frame rands env) cont))
              )
    (letrec-exp (p-names b-vars-list p-bodies body)
                (value-of/k body (eval-letrec-exp p-names b-vars-list p-bodies env) cont)
                )
    ; list
    (emptylist-exp () (apply-cont cont (eval-emptylist-exp)))
    (cons-exp (exp1 exp2)
              (value-of/k exp1 env (build-cont (cons-exp-frame-1 exp2 env) cont))
              )
    (null?-exp (exp1)
               (value-of/k exp1 env (build-cont (null?-exp-frame) cont))
               )
    (car-exp (exp1)
             (value-of/k exp1 env (build-cont (car-exp-frame) cont))
             )
    (cdr-exp (exp1)
             (value-of/k exp1 env (build-cont (cdr-exp-frame) cont))
             )
    (list-exp (exp1 exps)
              (value-of-exps/k (build-cont exp1 exps) env (build-cont (list-exp-frame) cont))
              )
    (begin-exp (exp1 exps)
               (value-of-exps/k (build-cont exp1 exps) env (build-cont (begin-exp-frame) cont))
               )
    (assign-exp (var exp1)
                (value-of/k exp1 env (build-cont (set-rhs-frame (apply-env env var)) cont))
                )
    (else (eopl:error "invalid exp ~s" exp))
    )
  )

(define (value-of-exps/k exps saved-env saved-cont)
  (value-of-exps-helper/k exps '() saved-env saved-cont)
  )

(define (value-of-exps-helper/k exps vals saved-env saved-cont)
  (if (null? exps)
      (apply-cont saved-cont vals)
      (let ((first-exp (car exps)) (rest-exps (cdr exps)))
        (value-of/k
         first-exp
         saved-env
         (build-cont (exps-frame rest-exps vals saved-env) saved-cont)
         )
        )
      )
  )
