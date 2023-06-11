Code in Figure 3.12

```racket
(define apply-env
    (lambda (env search-var)
      (cases environment env
        (empty-env () (report-no-binding-found search-var))
        (extend-env (saved-var saved-val saved-env)
            (if (eqv? saved-var search-var) saved-val
            (apply-env saved-env search-var)))
        (extend-env-rec (p-name b-var p-body saved-env)
            (if (eqv? search-var p-name)
                (proc-val (procedure b-var p-body env))
                (apply-env saved-env search-var))))))
```

proc-val is used to build the procedure letrec-exp defined
