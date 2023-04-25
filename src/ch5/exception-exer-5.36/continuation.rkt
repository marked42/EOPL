#lang eopl

(require racket/lazy-require racket/list)
(lazy-require
 ["../shared/basic.rkt" (identifier?)]
 ["../shared/eval.rkt" (
                        eval-diff-exp
                        eval-zero?-exp
                        eval-if-exp
                        eval-let-exp
                        eval-null?-exp
                        eval-cons-exp
                        eval-car-exp
                        eval-cdr-exp
                        eval-list-exp
                        eval-begin-exp
                        )]
 ["../shared/environment.rkt" (extend-env extend-mul-env environment?)]
 ["../shared/store.rkt" (setref reference? newref vals->refs)]
 ["../shared/value.rkt" (expval? expval->proc)]
 ["../shared/expression.rkt" (expression?)]
 ["../shared/procedure.rkt" (proc->procedure)]
 ["interpreter.rkt" (value-of/k value-of-exps/k value-of-exps-helper/k)]
 )

(provide (all-defined-out))

(define-datatype continuation cont?
  (end-cont)
  (diff-cont (saved-cont cont?) (exp2 expression?) (saved-env environment?))
  (diff-cont-1 (saved-cont cont?) (val1 expval?))
  (zero?-cont (saved-cont cont?))
  (if-cont (saved-cont cont?) (exp2 expression?) (exp3 expression?) (saved-env environment?))
  (exps-cont (saved-cont cont?) (exps (list-of expression?)) (vals (list-of expval?)) (saved-env environment?))
  (let-cont (saved-cont cont?) (vars (list-of identifier?)) (body expression?) (env environment?))
  (call-cont (saved-cont cont?) (rands (list-of expression?)) (saved-env environment?))
  (call-cont-1 (saved-cont cont?) (rator expval?))

  (cons-cont (saved-cont cont?) (exp2 expression?) (saved-env environment?))
  (cons-cont-1 (saved-cont cont?) (val1 expval?))
  (null?-cont (saved-cont cont?))
  (car-cont (saved-cont cont?))
  (cdr-cont (saved-cont cont?))
  (list-cont (saved-cont cont?))

  (begin-cont (saved-cont cont?))

  (set-rhs-cont (ref reference?) (saved-cont cont?))

  (try-cont (saved-cont cont?) (var identifier?) (handler-exp expression?) (saved-env environment?) (parent cont?))
  (raise-cont (saved-cont cont?))
  )

(define (apply-cont cont val try)
  (cases continuation cont
    (end-cont () val)
    (diff-cont (saved-cont exp2 saved-env)
               (value-of/k exp2 saved-env (diff-cont-1 saved-cont val) try)
               )
    (diff-cont-1 (saved-cont val1)
                 (apply-cont saved-cont (eval-diff-exp val1 val) try)
                 )
    (zero?-cont (saved-cont)
                (apply-cont saved-cont (eval-zero?-exp val) try)
                )
    (if-cont (saved-cont exp2 exp3 saved-env)
             (value-of/k (eval-if-exp val exp2 exp3) saved-env saved-cont try)
             )
    (exps-cont (saved-cont exps vals env)
               (value-of-exps-helper/k exps (append vals (list val)) env saved-cont try)
               )
    (let-cont (saved-cont vars body saved-env)
              (let ((vals val))
                (value-of/k body (eval-let-exp vars vals saved-env) saved-cont try)
                )
              )
    (call-cont (saved-cont rands saved-env)
               (let ((rator val))
                 (value-of-exps/k rands saved-env (call-cont-1 saved-cont rator) try)
                 )
               )
    (call-cont-1 (saved-cont rator)
                 (let ((proc1 (expval->proc rator)) (rands val))
                   (apply-procedure/k value-of/k proc1 rands saved-cont try)
                   )
                 )
    (cons-cont (saved-cont exp2 env)
               (value-of/k exp2 env (cons-cont-1 saved-cont val) try)
               )
    (cons-cont-1 (saved-cont val1)
                 (let ((val2 val))
                   (apply-cont saved-cont (eval-cons-exp val1 val2) try)
                   )
                 )
    (null?-cont (saved-cont)
                (apply-cont saved-cont (eval-null?-exp val) try)
                )
    (car-cont (saved-cont)
              (apply-cont saved-cont (eval-car-exp val) try)
              )
    (cdr-cont (saved-cont)
              (apply-cont saved-cont (eval-cdr-exp val) try)
              )
    (list-cont (saved-cont)
               (apply-cont saved-cont (eval-list-exp val) try)
               )
    (begin-cont (saved-cont)
                (let ((vals val))
                  (apply-cont saved-cont (eval-begin-exp vals) try)
                  )
                )
    (set-rhs-cont (ref saved-cont)
                  (setref ref val)
                  (apply-cont saved-cont val try)
                  )
    (try-cont (saved-cont var handler-exp saved-env parent)
              ; returns normally
              (apply-cont saved-cont val parent)
              )
    (raise-cont (saved-cont)
                (cases continuation try
                  (try-cont (saved-cont var handler-exp saved-env parent)
                            ; continue from try-cont, update enclosing try cont with parent
                            (value-of/k handler-exp (extend-env var (newref val) saved-env) saved-cont parent)
                            )
                  (else (report-uncaught-exception))
                  )
                )
    )
  )

(define (apply-procedure/k value-of/k proc1 args saved-cont try)
  (let ((procedure (proc->procedure proc1)))
    (let ((vars (first procedure)) (body (second procedure)) (saved-env (third procedure)))
      (value-of/k body (extend-mul-env vars (vals->refs args) saved-env) saved-cont try)
      )
    )
  )


(define (report-uncaught-exception val)
  (eopl:error 'uncaught-exception "Uncaught expcetion ~s " val)
  )
