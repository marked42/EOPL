#lang eopl

(require racket/lazy-require)
(lazy-require
 ["basic.rkt" (identifier?)]
 ["environment.rkt" (environment? extend-env)]
 ["value.rkt" (expval? num-val bool-val expval->proc expval->num expval->bool)]
 ["expression.rkt" (expression?)]
 ["procedure.rkt" (apply-procedure/k)]
 ["interpreter.rkt" (value-of/k)]
 )

(provide (all-defined-out))

(define-datatype continuation cont?
  (end-cont)
  (diff-cont (saved-cont cont?) (exp2 expression?) (saved-env environment?))
  (diff-cont-1 (saved-cont cont?) (val1 expval?))
  (zero?-cont (saved-cont cont?))
  (if-cont (saved-cont cont?) (exp2 expression?) (exp3 expression?) (saved-env environment?))
  (let-cont (saved-cont cont?) (var identifier?) (body expression?) (env environment?))
  (call-cont (saved-cont cont?) (rands expression?) (saved-env environment?))
  (call-cont-1 (saved-cont cont?) (rator expval?))
  )

(define (apply-cont cont val)
  (cases continuation cont
    (end-cont () val)
    (diff-cont (saved-cont exp2 saved-env)
               (value-of/k exp2 saved-env (diff-cont-1 saved-cont val))
               )
    (diff-cont-1 (saved-cont val1)
                 (let ((num1 (expval->num val1)) (num2 (expval->num val)))
                   (apply-cont saved-cont (num-val (- num1 num2)))
                   )
                 )
    (zero?-cont (saved-cont)
                (apply-cont saved-cont
                            (let ((num (expval->num val)))
                              (if (zero? num)
                                  (bool-val #t)
                                  (bool-val #f)
                                  )
                              )
                            )
                )
    (if-cont (saved-cont exp2 exp3 saved-env)
             (value-of/k (if (expval->bool val) exp2 exp3) saved-env saved-cont)
             )
    (let-cont (saved-cont var body saved-env)
              (value-of/k body (extend-env var val saved-env) saved-cont)
              )
    (call-cont (saved-cont rand saved-env)
               (let ((rator val))
                 (value-of/k rand saved-env (call-cont-1 saved-cont rator))
                 )
               )
    (call-cont-1 (saved-cont rator)
                 (let ((proc1 (expval->proc rator)) (rand val))
                   (apply-procedure/k proc1 rand saved-cont)
                   )
                 )
    )
  )
