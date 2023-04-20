#lang eopl

(require
  racket/lazy-require
  racket/list
  )
(lazy-require
 ["../shared/basic.rkt" (identifier?)]
 ["../shared/eval.rkt" (
                        eval-diff-exp
                        eval-zero?-exp
                        eval-let-exp
                        eval-null?-exp
                        eval-if-exp
                        eval-cons-exp
                        eval-car-exp
                        eval-cdr-exp
                        eval-list-exp
                        )]
 ["../shared/environment.rkt" (
                               extend-mul-env
                               environment?
                               )]
 ["../shared/store.rkt" (vals->refs setref reference?)]
 ["../shared/value.rkt" (expval? expval->proc cell-val)]
 ["../shared/expression.rkt" (expression?)]
 ["../shared/procedure.rkt" (apply-procedure/k)]
 ["interpreter.rkt" (value-of/k value-of-exps/k)]
 )

(provide (all-defined-out))

(define (end-cont) '())

(define (build-cont new-cont saved-cont)
  (cons new-cont saved-cont)
  )

(define (get-top-frame cont)
  (car cont)
  )

(define (get-saved-cont cont)
  (cdr cont)
  )

(define (apply-cont cont val)
  (if (null? cont)
      val
      (let ((top-frame (get-top-frame cont)) (saved-cont (get-saved-cont cont)))
        (cases frame top-frame
          (diff-frame-1 (exp2 saved-env)
                        (value-of/k exp2 saved-env
                                    (build-cont (diff-frame-2 val) saved-cont)
                                    )
                        )
          (diff-frame-2 (val1)
                        (apply-cont saved-cont (eval-diff-exp val1 val))
                        )
          (zero?-frame ()
                       (apply-cont saved-cont (eval-zero?-exp val))
                       )
          (if-frame (exp2 exp3 saved-env)
                    (value-of/k (eval-if-exp val exp2 exp3) saved-env saved-cont)
                    )
          (exps-frame (exps vals saved-env)
                      (value-of-exps/k exps (append vals (list val)) saved-env saved-cont)
                      )
          (let-frame (vars body saved-env)
                     (let ((vals val))
                       (value-of/k body (eval-let-exp vars vals saved-env) saved-cont)
                       )
                     )
          (call-exp-frame (rands saved-env)
                          (let ((rator val))
                            (value-of-exps/k rands '() saved-env (build-cont (call-exp-frame-1 rator) saved-cont))
                            )
                          )
          (call-exp-frame-1 (rator)
                            (let ((proc1 (expval->proc rator)) (rands val))
                              (apply-procedure/k value-of/k proc1 rands saved-cont)
                              )
                            )
          (cons-exp-frame-1 (exp2 saved-env)
                            (value-of/k exp2 saved-env (build-cont (cons-exp-frame-2 val) saved-cont))
                            )
          (cons-exp-frame-2 (val1)
                            (let ((val2 val))
                              (apply-cont saved-cont (eval-cons-exp val1 val2))
                              )
                            )
          (null?-exp-frame ()
                           (apply-cont saved-cont (eval-null?-exp val))
                           )
          (car-exp-frame ()
                         (apply-cont saved-cont (eval-car-exp val))
                         )
          (cdr-exp-frame ()
                         (apply-cont saved-cont (eval-cdr-exp val))
                         )
          (list-exp-frame ()
                          (let ((vals val))
                            (apply-cont saved-cont (eval-list-exp vals))
                            )
                          )
          (begin-exp-frame ()
                           (let ((vals val))
                             (apply-cont saved-cont (last vals))
                             )
                           )
          (set-rhs-frame (ref)
                         (setref ref val)
                         (apply-cont saved-cont val)
                         )
          (else (eopl:error "invalid frame type~s " top-frame))
          )
        )
      )
  )

(define-datatype frame frame?
  (diff-frame-1 (exp2 expression?) (saved-env environment?))
  (diff-frame-2 (val1 expval?))
  (zero?-frame)
  (if-frame (exp2 expression?) (exp3 expression?) (saved-env environment?))
  (exps-frame (exps (list-of expression?)) (vals (list-of expval?)) (saved-env environment?))
  (let-frame (vars (list-of identifier?)) (body expression?) (saved-env environment?))
  (call-exp-frame (rands (list-of expression?)) (saved-env environment?))
  (call-exp-frame-1 (rator expval?))
  (cons-exp-frame-1 (exp2 expression?) (saved-env environment?))
  (cons-exp-frame-2 (val1 expval?))
  (null?-exp-frame)
  (car-exp-frame)
  (cdr-exp-frame)
  (list-exp-frame)
  (begin-exp-frame)
  (set-rhs-frame (ref reference?))
  )
