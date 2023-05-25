#lang eopl

(require racket/lazy-require racket/set "../cps-lang/expression.rkt")
(lazy-require
 ["../transformer-book/transformer.rkt" (create-cps-of-program)]
 )

(provide (all-defined-out))

(define (make-send-to-cont k-exp simple-exp)
  (cases simple-expression k-exp
    (cps-proc-exp (vars body)
                  (if (= (length vars) 1)
                      (replace-free-variables body (car vars) simple-exp)
                      (cps-call-exp k-exp (list simple-exp))
                      )
                  )
    (else (cps-call-exp k-exp (list simple-exp)))
    )
  )

(define cps-of-program (create-cps-of-program make-send-to-cont))

(define (replace-free-variables exp target-var new-simple-exp)
  (replace-tfexp exp target-var new-simple-exp (set))
)

(define (replace-simple-exp simple-exp target-var new-simple-exp ids)
  (cases simple-expression simple-exp
    (cps-const-exp (num) simple-exp)
    (cps-var-exp (var)
      (if (and (equal? var target-var) (not (set-member? ids var)))
        new-simple-exp
        simple-exp
        )
    )
    (cps-diff-exp (simple1 simple2)
      (cps-diff-exp (replace-simple-exp simple1 target-var new-simple-exp ids) (replace-simple-exp simple2 target-var new-simple-exp ids))
    )
    (cps-zero?-exp (simple1)
      (cps-zero?-exp (replace-simple-exp simple1 target-var new-simple-exp ids))
    )
    (cps-proc-exp (vars body)
      (cps-proc-exp vars (replace-tfexp body target-var new-simple-exp (set-add-multiple ids vars)))
    )
    (cps-sum-exp (simple-exps)
      (cps-sum-exp (replace-simple-exps simple-exps target-var new-simple-exp ids))
    )
    (cps-list-exp (simple-exps)
      (cps-list-exp (replace-simple-exps simple-exps target-var new-simple-exp ids))
    )
  )
)

(define (replace-simple-exps simple-exps target-var new-simple-exp ids)
  (map (lambda (simple-exp) (replace-simple-exp simple-exp target-var new-simple-exp ids)) simple-exps)
)

(define (replace-tfexp exp target-var new-simple-exp ids)
  (cases tfexp exp
    (simple-exp->exp (simple) (simple-exp->exp (replace-simple-exp simple target-var new-simple-exp ids)))
    (cps-let-exp (vars simple-exps body)
      (cps-let-exp
        vars
        (replace-simple-exps simple-exps target-var new-simple-exp ids)
        (replace-tfexp body target-var new-simple-exp (set-add-multiple ids vars))
      )
    )
    (cps-letrec-exp (p-names b-varss p-bodies body)
      (cps-letrec-exp
        p-names
        b-varss
        (map (lambda (p-body b-vars) (replace-tfexp p-body target-var new-simple-exp (set-add-multiple ids b-vars))) p-bodies b-varss)
        (replace-tfexp body target-var new-simple-exp (set-add-multiple ids p-names))
      )
    )
    (cps-if-exp (simple1 exp2 exp3)
      (cps-if-exp
        (replace-simple-exp simple1 target-var new-simple-exp ids)
        (replace-tfexp exp2 target-var new-simple-exp ids)
        (replace-tfexp exp3 target-var new-simple-exp ids)
      )
    )
    (cps-call-exp (rator rands)
      (cps-call-exp
        (replace-simple-exp rator target-var new-simple-exp ids)
        (replace-simple-exps rands target-var new-simple-exp ids)
      )
    )
  )
)

(define (set-add-multiple st lst)
  (if (null? lst)
    st
    (set-add-multiple (set-add st (car lst)) (cdr lst))
  )
)
