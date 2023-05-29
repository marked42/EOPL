#lang eopl

(require racket/lazy-require racket/list "../cps-lang/expression.rkt")
(lazy-require
 ["../cps-lang/identifier.rkt" (fresh-identifier initialize-identifier-index!)]
 )

(provide (all-defined-out))

(define (make-send-to-cont k-exp simple-exp)
  (cps-call-exp k-exp (list simple-exp))
  )

(define (create-cps-of-program make-send-to-cont)
  (define (cps-of-program prog)
    (initialize-identifier-index!)
    (cases program prog
      (a-program (exp1)
                 (cps-a-program
                  (cps-of-exps (list exp1) (lambda (args) (simple-exp->exp (car args))))
                  )
                 )
      )
    )

  (define (cps-of-exp exp k-exp)
    (cases expression exp
      (const-exp (num) (make-send-to-cont k-exp (cps-const-exp num)))
      (var-exp (var) (make-send-to-cont k-exp (cps-var-exp var)))
      (zero?-exp (exp1) (cps-of-zero?-exp exp1 k-exp))
      (diff-exp (exp1 exp2) (cps-of-diff-exp exp1 exp2 k-exp))
      (call-exp (rator rands) (cps-of-call-exp rator rands k-exp))
      (let-exp (vars exps body)
               (cps-of-let-exp vars exps body k-exp)
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
      (list-exp (exps) (cps-of-list-exp exps k-exp))
      (else (eopl:error 'cps-of-exp "unsupported expression ~s " exp))
      )
    )

  (define (cps-of-zero?-exp exp1 k-exp)
    (cps-of-exps (list exp1) (lambda (simples)
                               (make-send-to-cont k-exp (cps-zero?-exp (car simples)))
                               ))
    )

  (define (cps-of-sum-exp exps k-exp)
    (cps-of-exps exps (lambda (simples)
                        (make-send-to-cont k-exp (cps-sum-exp simples))
                        ))
    )

  (define (cps-of-list-exp exps k-exp)
    (cps-of-exps exps (lambda (simples)
                        (make-send-to-cont k-exp (cps-list-exp simples))
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

  (define (cps-of-let-exp vars exps body k-exp)
    (if (= (length vars))
      ; exercise 6.27
      (let ((var (car vars)) (exp (car exps)))
        (cps-of-exp exp (cps-proc-exp (list var) (cps-of-exp body k-exp)))
      )
      (cps-of-exps
        exps
        (lambda (simples)
          (cps-let-exp vars simples (cps-of-exp body k-exp))
          )
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

  (lambda (prog) (cps-of-program prog))
  )

(define cps-of-program (create-cps-of-program make-send-to-cont))