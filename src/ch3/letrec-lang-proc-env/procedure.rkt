#lang eopl

(require racket/lazy-require "basic.rkt" "environment.rkt")
(lazy-require
 ["expression.rkt" (expression?)]
 ["environment.rkt" (environment?)]
 ["interpreter.rkt" (value-of-exp)])

(provide (all-defined-out))

(define-datatype proc proc?
  (procedure
   (vars (list-of identifier?))
   (body expression?)
   (saved-env environment?)
   )
  (trace-procedure
   (vars (list-of identifier?))
   (body expression?)
   (saved-env environment?)
   )
  )

(define (apply-procedure proc1 args)
  (cases proc proc1
    (procedure (vars body saved-env)
               (value-of-exp body (extend-mul-env vars args saved-env))
               )
    (trace-procedure (vars body saved-env)
                     (display "entering proc~n" )
                     (newline)
                     (let ((res (value-of-exp body (extend-mul-env vars args saved-env))))
                       (display "exiting proc~n" )
                       (newline)
                       res
                       )
                     )
    )
  )
