#lang eopl

(require racket/lazy-require)
(lazy-require
    ["expression.rkt" (expression?)]
    ["environment.rkt" (environment?)]
    ["interpreter.rkt" (value-of-exp)]
)

(provide (all-defined-out))

(define-datatype thunk thunk?
    (a-thunk (exp1 expression?) (env environment?))
)

(define (value-of-thunk th)
    (cases thunk th
        (a-thunk (exp1 env)
            (value-of-exp exp1 env)
        )
    )
)
