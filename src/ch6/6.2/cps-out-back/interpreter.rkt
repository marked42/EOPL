#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env
                     build-circular-extend-env-rec-mul-vec
                     )]
 ["continuation.rkt" (apply-cont end-cont)]
 ["procedure.rkt" (apply-procedure procedure)])

(provide (all-defined-out))

(define (run str)
  (let ((prog (scan&parse str)))
    (let ((cps-prog (cps-of-program prog)))
      (value-of-program cps-prog)
      )
    )
  )

(define (value-of-program cps-prog)
  (cases cps-program cps-prog
    (cps-a-program (exp1)
                   (value-of/k exp1 (init-env) (end-cont))
                   )
    )
  )

(define (cps-of-program prog)
  (cases program prog
    (a-program (exp1)
               (cps-a-program
                (cps-of-exps (list exp1) (lambda (args) (simple-exp->exp (car args))))
                )
               )
    )
  )

(define fresh-identifier
  (let ((sn 0))
    (lambda (identifier)
      (set! sn (+ sn 1))
      (string->symbol
       (string-append
        (symbol->string identifier)
        "%"             ; this can't appear in an input identifier
        (number->string sn))))))

(define (make-send-to-cont k-exp simple-exp)
  (cps-call-exp k-exp (list simple-exp))
  )

(define (cps-of-exp exp k-exp)
  (cases expression exp
    (const-exp (num) (make-send-to-cont k-exp (cps-const-exp num)))
    (var-exp (var) (make-send-to-cont k-exp (cps-var-exp var)))
    (diff-exp (exp1 exp2) (cps-of-diff-exp exp1 exp2 k-exp))
    (call-exp (rator rands) (cps-of-call-exp rator rands k-exp))
    (let-exp (var exp1 body)
             (cps-of-let-exp var exp1 body k-exp)
             )
    (proc-exp (vars body)
              (make-send-to-cont k-exp
                                 (cps-proc-exp (append vars (list 'k%00)) (cps-of-exp body (cps-var-exp 'k%00))))
              )
    (if-exp (exp1 exp2 exp3)
            (cps-of-if-exp exp1 exp2 exp3 k-exp)
            )
    (letrec-exp (p-names b-varss p-bodies body)
                (cps-of-letrec-exp p-names b-varss p-bodies body k-exp)
                )
    (sum-exp (exps) (cps-of-sum-exp exps k-exp))
    (else (eopl:error 'cps-of-exp "unsupported expression ~s " exp))
    )
  )

(define (cps-of-sum-exp exps k-exp)
  (cps-of-exps exps (lambda (simples)
                      (make-send-to-cont k-exp (cps-sum-exp simples))
                      ))
  )

(define (cps-of-letrec-exp p-names b-varss p-bodies body k-exp)
  (cps-letrec-exp
   p-names
   (map (lambda (b-vars) (append b-vars (list 'k%00))) b-varss)
   (map (lambda (p-body) (cps-of-exp p-body (cps-var-exp 'k%00))) p-bodies)
   (cps-of-exp body k-exp)
   )
  )

(define (cps-of-let-exp var exp1 body k-exp)
  (cps-of-exps
   (list exp1)
   (lambda (simples)
     (cps-let-exp var (car simples) (cps-of-exp body k-exp))
     )
   )
  )

(define (cps-of-diff-exp exp1 exp2 k-exp)
  (cps-of-exps (list exp1 exp2)
               (lambda (simples)
                 (make-send-to-cont k-exp
                                    (cps-diff-exp (car simples) (cadr simples))
                                    )
                 )
               )
  )

(define (cps-of-call-exp rand rands k-exp)
  (cps-of-exps (cons rand rands)
               (lambda (simples)
                 (cps-call-exp
                  (car simples)
                  (append (cdr simples) (list k-exp))
                  )
                 )
               )
  )

(define (cps-of-if-exp exp1 exp2 exp3 k-exp)
  (cps-of-exps
   (list exp1)
   (lambda (vals)
     (cps-if-exp (first vals)
                 (cps-of-exp exp2 k-exp)
                 (cps-of-exp exp3 k-exp)
                 )
     )
   )
  )

(define (cps-of-exps exps builder)
  (let cps-of-rest ((exps exps))
    (let ((pos (index-where
                exps
                (lambda (exp) (not (inp-exp-simple? exp)))
                )))
      (if (not pos)
          (builder (map cps-of-simple-exp exps))
          (let ((var (fresh-identifier 'var)))
            (cps-of-exp
             (list-ref exps pos)
             (cps-proc-exp (list var)
                           (cps-of-rest (list-set exps pos (var-exp var)))
                           )
             )
            )
          )
      )
    )
  )

(define (inp-exp-simple? exp)
  (cases expression exp
    (const-exp (num) #t)
    (var-exp (var) #t)
    (diff-exp (exp1 exp2)
              (and (inp-exp-simple? exp1) (inp-exp-simple? exp2))
              )
    (zero?-exp (exp1) (inp-exp-simple? exp1))
    (proc-exp (vars exp) #t)
    (sum-exp (exps) (every? inp-exp-simple? exps))
    (else #f)
    )
  )

(define (every? pred lst)
  (if (null? lst)
      #t
      (let ((first (pred (car lst))))
        (if first
            (every? pred (cdr lst))
            #f
            )
        )
      )
  )

(define (cps-of-simple-exp exp)
  (cases expression exp
    (const-exp (num) (cps-const-exp num))
    (var-exp (var) (cps-var-exp var))
    (diff-exp (exp1 exp2) (cps-diff-exp (cps-of-simple-exp exp1) (cps-of-simple-exp exp2)))
    (zero?-exp (exp1) (cps-zero?-exp (cps-of-simple-exp exp1)))
    (proc-exp (vars body)
              (cps-proc-exp (append vars (list 'k%00)) (cps-of-exp body (cps-var-exp 'k%00)))
              )
    (sum-exp (exps) (cps-sum-exp (map cps-of-simple-exp exps)))
    (else (report-invalid-exp-to-cps-of-simple-exp exp))
    )
  )

(define (report-invalid-exp-to-cps-of-simple-exp exp)
  (eopl:error 'cps-of-simple-exp "non-simple expression to cps-of-simple-exp: ~s" exp)
  )

(define (value-of/k exp env cont)
  (cases tfexp exp
    (simple-exp->exp (simple)
                     (apply-cont cont (value-of-simple-exp simple env))
                     )
    (cps-if-exp (exp1 exp2 exp3)
                (let ((val1 (value-of-simple-exp exp1 env)))
                  (if (expval->bool val1)
                      (value-of/k exp2 env cont)
                      (value-of/k exp3 env cont)
                      )
                  )
                )
    (cps-let-exp (var exp1 body)
                 (let ((val (value-of-simple-exp exp1 env)))
                   (value-of/k body (extend-env var val env) cont)
                   )
                 )
    (cps-letrec-exp (p-names b-vars-list p-bodies body)
                    (let ((new-env (build-circular-extend-env-rec-mul-vec p-names b-vars-list p-bodies env)))
                      (value-of/k body new-env cont)
                      )
                    )
    (cps-call-exp (rator rands)
                  (let ((rator-val (value-of-simple-exp rator env)) (rand-vals (value-of-simple-exps rands env)))
                    (let ((proc1 (expval->proc rator-val)))
                      (apply-procedure proc1 rand-vals cont)
                      )
                    )
                  )
    (else (eopl:error 'value-of/k "invalid expression ~s" exp))
    )
  )

(define (value-of-simple-exp exp1 env)
  (cases simple-expression exp1
    (cps-const-exp (num) (num-val num))
    (cps-var-exp (var) (apply-env env var))
    (cps-diff-exp (exp1 exp2)
                  (let ((val1 (value-of-simple-exp exp1 env))
                        (val2 (value-of-simple-exp exp2 env)))
                    (let ((num1 (expval->num val1))
                          (num2 (expval->num val2)))
                      (num-val (- num1 num2))
                      )
                    )
                  )
    ; true only if exp1 is number 0
    (cps-zero?-exp (exp1)
                   (let ((val (value-of-simple-exp exp1 env)))
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
                                 (value-of-simple-exp exp env)))
                              exps)))
                   (num-val
                    (let sum-loop ((nums nums))
                      (if (null? nums) 0
                          (+ (car nums) (sum-loop (cdr nums))))))))
    (else (eopl:error 'value-of-simple-exp "unsupported simple-expression ~s " exp1))
    )
  )

(define (value-of-simple-exps exps env)
  (map (lambda (exp1) (value-of-simple-exp exp1 env)) exps)
  )
