#lang eopl

(require racket/list)

(define (cps-of-call-exp rator rands k-exp)
  (cps-of-exps (cons rands rator)
               (lambda (simples)
                 (cps-call-exp
                  (get-operator simples)
                  (append (get-operands simples) (list k-exp))
                  )
                 )
               )
  )

(define (get-operator simples)
  (last simples)
  )

(define (get-operands simples)
  (if (= (length simples) 1)
      '()
      (cons (car simples) (get-operands (cdr simples)))
      )
  )
