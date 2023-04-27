#lang eopl

(require
  racket/lazy-require
  racket/list
  ; use program and expression datatype
  "../shared/expression.rkt"
  )
(lazy-require
 ["../shared/store.rkt" (initialize-store! newref)]
 ["../shared/parser.rkt" (scan&parse)]
 ["value.rkt" (cont-val)]
 ["environment.rkt" (init-env apply-env extend-env)]
 ["eval.rkt" (
              eval-const-exp
              eval-var-exp
              eval-proc-exp
              eval-letrec-exp
              eval-emptylist-exp
              )]
 ["continuation.rkt" (
                      end-cont
                      apply-cont
                      diff-cont
                      zero?-cont
                      if-cont
                      exps-cont
                      let-cont
                      call-cont
                      cons-cont
                      null?-cont
                      car-cont
                      cdr-cont
                      list-cont
                      begin-cont
                      set-rhs-cont
                      try-cont
                      raise-cont
                      throw-cont
                      )]
 )

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  (initialize-store!)
  (cases program prog
    (a-program (exp1)
               (let ((translated-exp (translate-exp exp1)))
                 (value-of/k translated-exp (init-env) (end-cont))
                 )
               )
    )
  )

(define (translate-exps exps)
  (map translate-exp exps)
  )

(define (translate-exp exp1)
  (cases expression exp1
    (zero?-exp (exp1)
               (zero?-exp (translate-exp exp1))
               )
    (if-exp (exp1 exp2 exp3)
            (if-exp (translate-exp exp1) (translate-exp exp2) (translate-exp exp3))
            )
    (let-exp (vars exps body)
             (let-exp vars (translate-exps exps) (translate-exp body))
             )
    (proc-exp (first-var rest-vars body)
              (proc-exp first-var rest-vars (translate-exp body))
              )
    (call-exp (rator rands)
              (call-exp (translate-exp rator) (translate-exps rands))
              )
    (letrec-exp (p-names b-vars-list p-bodies body)
                (letrec-exp p-names b-vars-list (translate-exps p-bodies) (translate-exp body))
                )
    (cons-exp (exp1 exp2)
              (cons-exp (translate-exp exp1) (translate-exp exp2))
              )
    (null?-exp (exp1)
               (null?-exp (translate-exp exp1))
               )
    (car-exp (exp1)
             (car-exp (translate-exp exp1))
             )
    (cdr-exp (exp1)
             (cdr-exp (translate-exp exp1))
             )
    (list-exp (exp1 exps)
              (list-exp (translate-exp exp1) (translate-exps exps))
              )
    (begin-exp (exp1 exps)
               (begin-exp (translate-exp exp1) (translate-exps exps))
               )
    (assign-exp (var exp1)
                (assign-exp var (translate-exp exp1))
                )
    (try-exp (exp1 var handler-exp)
             (try-exp (translate-exp exp1) var (translate-exp handler-exp))
             )
    (raise-exp (exp1)
               (raise-exp (translate-exp exp1))
               )
    (letcc-exp (var body)
               (call-exp (var-exp 'callcc) (list (proc-exp var '() (translate-exp body))))
               )
    (throw-exp (exp1 exp2) (call-exp (translate-exp exp2) (list (translate-exp exp1))))
    (diff-exp (exp1 exp2) (diff-exp (translate-exp exp1) (translate-exp exp2)))
    (else exp1)
    )
  )

(define (value-of/k exp env cont)
  (cases expression exp
    (const-exp (num) (apply-cont cont (eval-const-exp num)))
    (diff-exp (exp1 exp2)
              (value-of/k exp1 env (diff-cont cont exp2 env))
              )
    (zero?-exp (exp1)
               (value-of/k exp1 env (zero?-cont cont))
               )
    (if-exp (exp1 exp2 exp3)
            (value-of/k exp1 env (if-cont cont exp2 exp3 env))
            )
    (var-exp (var)
             (apply-cont cont (eval-var-exp env var))
             )
    (let-exp (vars exps body)
             (value-of-exps/k exps env (let-cont cont vars body env))
             )
    (proc-exp (first-var rest-vars body)
              (apply-cont cont (eval-proc-exp first-var rest-vars body env))
              )
    (call-exp (rator rands)
              (value-of/k rator env (call-cont cont rands env))
              )
    (letrec-exp (p-names b-vars-list p-bodies body)
                (value-of/k body (eval-letrec-exp p-names b-vars-list p-bodies env) cont)
                )
    ; list
    (emptylist-exp () (apply-cont cont (eval-emptylist-exp)))
    (cons-exp (exp1 exp2)
              (value-of/k exp1 env (cons-cont cont exp2 env))
              )
    (null?-exp (exp1)
               (value-of/k exp1 env (null?-cont cont))
               )
    (car-exp (exp1)
             (value-of/k exp1 env (car-cont cont))
             )
    (cdr-exp (exp1)
             (value-of/k exp1 env (cdr-cont cont))
             )
    (list-exp (exp1 exps)
              (value-of-exps/k (cons exp1 exps) env (list-cont cont))
              )
    (begin-exp (exp1 exps)
               (value-of-exps/k (cons exp1 exps) env (begin-cont cont))
               )
    (assign-exp (var exp1)
                (value-of/k exp1 env (set-rhs-cont cont (apply-env env var)))
                )
    (try-exp (exp1 var handler-exp)
             (value-of/k exp1 env (try-cont cont var handler-exp env))
             )
    (raise-exp (exp1)
               (value-of/k exp1 env (raise-cont cont))
               )
    (letcc-exp (var body)
               (value-of/k body (extend-env var (newref (cont-val cont)) env) cont)
               )
    (throw-exp (exp1 exp2)
               (value-of/k exp1 env (throw-cont cont exp2 env))
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
        (value-of/k first-exp saved-env
                    (exps-cont saved-cont rest-exps vals saved-env)
                    )
        )
      )
  )
