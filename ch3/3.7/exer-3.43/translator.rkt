#lang eopl

(require racket/lazy-require "expression.rkt")
(lazy-require
 ["static-environment.rkt" (
                            init-senv
                            apply-senv
                            extend-senv
                            extend-senv-normal
                            )]
 )

(provide (all-defined-out))

(define (translation-of-program prog)
  (cases program prog
    (a-program (exp1)
               (a-program (translation-of-exp exp1 (init-senv)))
               )
    )
  )

(define (translation-of-exp exp senv)
  (cases expression exp
    (const-exp (num) exp)
    (diff-exp (exp1 exp2)
              (diff-exp
               (translation-of-exp exp1 senv)
               (translation-of-exp exp2 senv)
               )
              )
    (zero?-exp (exp1)
               (zero?-exp (translation-of-exp exp1 senv))
               )
    (if-exp (exp1 exp2 exp3)
            (if-exp
             (translation-of-exp exp1 senv)
             (translation-of-exp exp2 senv)
             (translation-of-exp exp3 senv)
             )
            )
    ; (var-exp (var) (let* ([pair (apply-senv senv var)] [depth (car pair)])
    ;                  (nameless-var-exp depth)
    ;                  )
    ;          )
    (var-exp (var) (let* ([pair (apply-senv senv var)] [depth (car pair)] [val (cdr pair)] [gap-env-count (+ 1 depth)])
                     ; when a var is references, if is a proc
                     (if val
                         ; adjust it's internal intermediary-nameless-var-exp index, should add the offset
                         ; of current var def and the location of the proc it refrences
                         (intermediary-nameless-var-exp->nameless-var-exp val gap-env-count)
                         (nameless-var-exp depth)
                         )
                     )
             )
    ; translation-of-exp doesn't change intermediary-nameless-exp
    (intermediary-nameless-var-exp (num) exp)
    (let-exp (var exp1 body)
             (nameless-let-exp
              ; translate proc as always, not used anymore when interpreted
              (translation-of-exp exp1 senv)
              ; when exp1 is a proc, transform its internal vars which referenes external definitions
              ; to intermediay-nameless-var-exp, remember this new-proc-exp in environment for later use.
              (if (is-proc-exp? exp1)
                  (let* ([proc-exp-with-intermediary-var (var-exp->intermediary-nameless-var-exp exp1 senv 0)]
                         [new-proc-exp (translation-of-exp proc-exp-with-intermediary-var senv)]
                         )
                    (translation-of-exp body (extend-senv var new-proc-exp senv))
                    )
                  (translation-of-exp body (extend-senv-normal var senv))
                  )
              )
             )
    (proc-exp (var body)
              (nameless-proc-exp
               (translation-of-exp body (extend-senv-normal var senv))
               )
              )
    (call-exp (rator rand)
              (call-exp
               (translation-of-exp rator senv)
               (translation-of-exp rand senv)
               )
              )
    (else (eopl:error 'translation-of-exp "unsupported expression type ~s" exp))
    )
  )

; transform var-exp which references vars of external defintions
; start from limit 0, increase limit by 1 when defining new variales,
; variables with depth greater than limit are those defined outside proc
; keep other expression unchanged
(define (var-exp->intermediary-nameless-var-exp exp senv limit)
  (cases expression exp
    (const-exp (num) exp)
    (diff-exp (exp1 exp2)
              (diff-exp
               (var-exp->intermediary-nameless-var-exp exp1 senv limit)
               (var-exp->intermediary-nameless-var-exp exp2 senv limit)
               )
              )
    (zero?-exp (exp1)
               (zero?-exp (var-exp->intermediary-nameless-var-exp exp1 senv limit))
               )
    (if-exp (exp1 exp2 exp3)
            (if-exp
             (var-exp->intermediary-nameless-var-exp exp1 senv limit)
             (var-exp->intermediary-nameless-var-exp exp2 senv limit)
             (var-exp->intermediary-nameless-var-exp exp3 senv limit)
             )
            )
    (var-exp (var) (let* ([pair (apply-senv senv var)] [depth (car pair)])
                     (if (>= depth limit)
                         (intermediary-nameless-var-exp depth)
                         exp
                         )
                     )
             )
    (intermediary-nameless-var-exp (num) exp)
    (let-exp (var exp1 body)
             (let-exp
              var
              (var-exp->intermediary-nameless-var-exp exp1 senv)
              (var-exp->intermediary-nameless-var-exp body (extend-senv-normal var senv) (+ limit 1))
              )
             )
    (proc-exp (var body)
              (proc-exp
               var
               (var-exp->intermediary-nameless-var-exp body (extend-senv-normal var senv) (+ limit 1))
               )
              )
    (call-exp (rator rand)
              (call-exp
               (var-exp->intermediary-nameless-var-exp rator senv limit)
               (var-exp->intermediary-nameless-var-exp rand senv limit)
               )
              )
    (else (eopl:error 'var-exp->intermediary-nameless-var-exp "unsupported expression type ~s" exp))
    )
  )

; transform intermediary-nameless-var-exp to nameless-var-exp and add offset to depth
(define (intermediary-nameless-var-exp->nameless-var-exp exp offset)
  (cases expression exp
    (const-exp (num) exp)
    (diff-exp (exp1 exp2)
              (diff-exp
               (intermediary-nameless-var-exp->nameless-var-exp exp1 offset)
               (intermediary-nameless-var-exp->nameless-var-exp exp2 offset)
               )
              )
    (zero?-exp (exp1)
               (zero?-exp (intermediary-nameless-var-exp->nameless-var-exp exp1 offset))
               )
    (if-exp (exp1 exp2 exp3)
            (if-exp
             (intermediary-nameless-var-exp->nameless-var-exp exp1 offset)
             (intermediary-nameless-var-exp->nameless-var-exp exp2 offset)
             (intermediary-nameless-var-exp->nameless-var-exp exp3 offset)
             )
            )
    (call-exp (rator rand)
              (call-exp
               (intermediary-nameless-var-exp->nameless-var-exp rator offset)
               (intermediary-nameless-var-exp->nameless-var-exp rand offset)
               )
              )

    (nameless-var-exp (num) exp)
    (nameless-let-exp (exp1 body)
                      (nameless-let-exp
                       (intermediary-nameless-var-exp->nameless-var-exp exp1 offset)
                       (intermediary-nameless-var-exp->nameless-var-exp body offset)
                       )
                      )
    (nameless-proc-exp (body)
                       (nameless-proc-exp
                        (intermediary-nameless-var-exp->nameless-var-exp body offset)
                        )
                       )

    (intermediary-nameless-var-exp (num) (nameless-var-exp (+ num offset)))
    (else (eopl:error 'intermediary-nameless-var-exp->nameless-var-exp "unsupported expression type ~s" exp))
    )
  )
