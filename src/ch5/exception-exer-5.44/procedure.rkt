#lang eopl

(require racket/lazy-require racket/list)
(lazy-require
 ["../shared/expression.rkt" (expression?)]
 ["../shared/basic.rkt" (identifier?)]
 ["../shared/store.rkt" (vals->refs)]
 ["environment.rkt" (environment? extend-mul-env)]
 ["value.rkt" (expval->proc proc-val)]
 ["continuation.rkt" (cont? apply-cont)]
 )

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (vars (list-of identifier?))
   (body expression?)
   (saved-env environment?)
   )
  (call/cc-procedure)
  (cont-procedure (cont cont?))
  )

(define (proc->procedure proc1)
  (cases proc proc1
    (procedure (vars body saved-env)
               (list vars body saved-env)
               )
    (else (eopl:error 'proc->procedure "invalid proc ~s " proc1))
    )
  )

(define (apply-procedure/k value-of/k proc1 args saved-cont)
  (cases proc proc1
    (procedure (vars body saved-env)
               ; create new ref under implicit refs, aka call-by-value
               (value-of/k body (extend-mul-env vars (vals->refs args) saved-env) saved-cont)
               )
    (call/cc-procedure ()
                       (if (not (= (length args)))
                           (eopl:error 'callcc "accepts only single argument, got ~s " args)
                           (let ((invoked-proc (expval->proc (car args))))
                             (apply-procedure/k value-of/k invoked-proc (list (proc-val (cont-procedure saved-cont))) saved-cont)
                             )
                           )
                       )
    (cont-procedure (cont) cont
                    (if (not (= (length args)))
                        (eopl:error 'cont-procedure "accepts only single argument, got ~s " args)
                        (apply-cont cont (car args))
                        )
                    )
    )
  )
