#lang eopl

(require
  racket/lazy-require
  racket/list
  )

(lazy-require
 ["../shared/procedure.rkt" (proc->procedure)]
 ["../shared/environment.rkt" (
                               extend-mul-env
                               )]
 ["../shared/store.rkt" (vals->refs)]
 ["interpreter.rkt" (value-of/k)]
 )

(provide (all-defined-out))

(define (apply-procedure/k proc1 args saved-cont)
  (let ((procedure (proc->procedure proc1)))
    (let ((vars (first procedure)) (body (second procedure)) (saved-env (third procedure)))
      ; create new ref under implicit refs, aka call-by-value
      (value-of/k body (extend-mul-env vars (vals->refs args) saved-env) saved-cont)
      )
    )
  )
