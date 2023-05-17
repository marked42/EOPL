#lang eopl

(define (cps-of-exp/ctx exp context)
    (if (inp-exp-simple? exp)
        (contex (cps-of-simple-exp exp))
        (let ((var (fresh-identifier 'var)))
            (cps-of-exp exp
                (cps-proc-exp (list var)
                    (context (cps-var-exp var))
                )
            )
        )
    )
)

(define (cps-of-diff-exp exp1 exp2 k-exp)
    (cps-of-exp/ctx exp1 (lambda (var1))
        (cps-of-exp/ctx exp2 (lambda (var2))
            (make-send-to-cont k-exp (cps-diff-exp var1 var2))
        )
    )
)


(define (cps-of-call-exp rator rands k-exp)
    (cps-of-exp/ctx rator (lambda (rator-simple))
        (cps-of-exps rands (lambda (rands-simples)
            (cps-call-exp rator-simple (append rands-simples (list k-exp)))
        ))
    )
)
