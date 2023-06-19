#lang eopl

(require racket/lazy-require racket/list "expression.rkt")
(lazy-require
 ["value.rkt" (num-val expval? proc-val)]
 ["store.rkt" (reference? newref)]
 ["procedure.rkt" (procedure)]
 )
(provide (all-defined-out))

(define-datatype environment environment?
  (empty-env)
  (extend-env*
   (vars (list-of symbol?))
   (vals (list-of (lambda (val) (or (reference? val) (vector? val)))))
   (saved-env environment?)
   )
  )

(define (extend-env-rec* p-names b-vars p-bodies saved-env)
  (let ([vectors (map (lambda (p-name) (make-vector 1)) p-names)])
    (let ([new-env (extend-env* p-names vectors saved-env)])
      (map (lambda (vec b-var p-body)
        (vector-set!
          vec
          0
          ; procedure body recursive refers to new-env
          (proc-val (procedure b-var p-body new-env))
          )
      ) vectors b-vars p-bodies)
      new-env
    )
  )
  )

(define (init-env)
  ; new stuff
  (extend-env*
    (list 'i 'v 'x)
    (list (newref (num-val 1)) (newref (num-val 5)) (newref (num-val 10)))
    (empty-env)
    )
  )

(define (apply-env env search-var)
  (cases environment env
    (extend-env* (vars vals saved-env)
                (let ([index (index-of vars search-var)])
                  (if index
                      (list-ref vals index)
                      (apply-env saved-env search-var)
                      )
                  )
                )
    (else (report-no-binding-found search-var))
    )
  )

(define (report-no-binding-found var)
  (eopl:error 'apply-env "No binding for ~s" var)
  )
