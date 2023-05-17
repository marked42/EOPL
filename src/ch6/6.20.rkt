#lang eopl

(define (cps-of-exps exps builder)
  (let cps-of-rest ((exps exps))
    (let ((pos (last-index-where
                exps
                (lambda (exp) (not (inp-exp-simple? exp)))
                )))
      (if (not pos)
          (builder (map cps-of-simple-exp exps))
          (let ((var (fresh-identifier 'var)))
            (cps-of-exp
             (list-ref exps pos)
             (cps-proc-exp (list var)
                           (cps-of-rest (list-set exps pos (var-exp var)))
                           )
             )
            )
          )
      )
    )
  )

(define (last-index-where exps pred)
    (let ((reversed-exps (reverse exps)))
        (- (length exps) (index-where reversed-exps pred))
    )
)
