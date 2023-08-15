#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-nameless-env
                     apply-nameless-env
                     extend-nameless-env
                     )]
 ["value.rkt" (num-val expval->num bool-val expval->bool proc-val expval->proc null-val null-val? cell-val cell-val->first cell-val->second)]
 ["procedure.rkt" (procedure apply-procedure proc->body)]
 ["store.rkt" (initialize-store! newref deref setref! show-store)]
 ["class.rkt" (initialize-class-env! find-method)]
 ["method.rkt" (apply-method self-index super-index)]
 ["object.rkt" (object->class-name new-object)]
 ["translator/main.rkt" (translation-of-program)]
 ["var-index.rkt" (var-index->depth var-index->offset)]
 )

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  ; new stuff
  (initialize-store!)
  (let ([translated-prog (translation-of-program prog)])
    (cases program translated-prog
      (a-program (class-decls exp1)
                 (initialize-class-env! class-decls)
                 (value-of-exp exp1 (init-nameless-env))
                 )
      )
    )
  )

(define (value-of-exp exp env)
  (cases expression exp
    (const-exp (num) (num-val num))
    (diff-exp (exp1 exp2)
              (let ([val1 (value-of-exp exp1 env)]
                    [val2 (value-of-exp exp2 env)])
                (let ((num1 (expval->num val1))
                      (num2 (expval->num val2)))
                  (num-val (- num1 num2))
                  )
                )
              )
    (sum-exp (exp1 exp2)
             (let ([val1 (value-of-exp exp1 env)]
                   [val2 (value-of-exp exp2 env)])
               (let ((num1 (expval->num val1))
                     (num2 (expval->num val2)))
                 (num-val (+ num1 num2))
                 )
               )
             )
    (zero?-exp (exp1)
               (let ([val (value-of-exp exp1 env)])
                 (let ([num (expval->num val)])
                   (if (zero? num)
                       (bool-val #t)
                       (bool-val #f)
                       )
                   )
                 )
               )
    (if-exp (exp1 exp2 exp3)
            (let ([val1 (value-of-exp exp1 env)])
              (if (expval->bool val1)
                  (value-of-exp exp2 env)
                  (value-of-exp exp3 env)
                  )
              )
            )
    (call-exp (rator rands)
              (let ((rator-val (value-of-exp rator env)) (rand-vals (value-of-exps rands env)))
                (let ((proc1 (expval->proc rator-val)))
                  (apply-procedure proc1 rand-vals)
                  )
                )
              )
    (begin-exp (exp1 exps)
               (let value-of-begin-exps ([exps (cons exp1 exps)])
                 (if (null? exps)
                     (eopl:error 'value-of-exp "begin expression should have at lease one expression")
                     (let ((first-exp (car exps)) (rest-exps (cdr exps)))
                       ; always calculate first exp cause it may has side effects
                       (let ((first-val (value-of-exp first-exp env)))
                         (if (null? rest-exps)
                             first-val
                             (value-of-begin-exps rest-exps)
                             )
                         )
                       )
                     )
                 )
               )
    (cons-exp (exp1 exp2)
              (let ([val1 (value-of-exp exp1 env)] [val2 (value-of-exp exp2 env)])
                (cell-val val1 val2)
                )
              )
    (car-exp (exp1)
             (let ([val1 (value-of-exp exp1 env)])
               (cell-val->first val1)
               )
             )
    (cdr-exp (exp1)
             (let ([val1 (value-of-exp exp1 env)])
               (cell-val->second val1)
               )
             )
    (emptylist-exp () (null-val))
    (null?-exp (exp1)
               (let ([val1 (value-of-exp exp1 env)])
                 (bool-val (null-val? val1))
                 )
               )
    (list-exp (exps)
              (let ([vals (value-of-exps exps env)])
                (let build-list ([vals vals])
                  (if (null? vals)
                      (null-val)
                      (let ((first (car vals)) (rest (cdr vals)))
                        (cell-val first (build-list rest))
                        )
                      )
                  )
                )
              )

    ; translation
    (nameless-var-exp (index)
                      (let ([ref (apply-nameless-env env index)])
                        (deref ref)
                        )
                      )
    (nameless-let-exp (exps body)
                      (let ([vals (value-of-exps exps env)])
                        (value-of-exp body (extend-nameless-env (map newref vals) env))
                        )
                      )
    (nameless-proc-exp (body)
                       (proc-val (procedure body env))
                       )
    (nameless-assign-exp (index exp1)
                         (let ([val1 (value-of-exp exp1 env)])
                           (setref! (apply-nameless-env env index) val1)
                           )
                         )
    (nameless-letrec-exp (p-bodies body)
                         (let ([procs (map (lambda (p-body) (newref (proc-val (procedure p-body env)))) p-bodies)])
                           (value-of-exp body (extend-nameless-env procs env))
                           )
                         )
    ; refer to exer 3.40
    (nameless-letrec-var-exp (index)
                             ; list-tail find tail part of list starting from target element
                             (let ([new-nameless-env (list-tail env (var-index->depth index))])
                               ; so car of new-nameless-env is the-proc corresponding to letrec-var
                               (let ([the-proc (expval->proc (deref (list-ref (car new-nameless-env) (var-index->offset index))))])
                                 (proc-val (procedure (proc->body the-proc) new-nameless-env))
                                 )
                               )
                             )
    (new-object-exp (class-name rands)
                    (let ([args (value-of-exps rands env)] [obj (new-object class-name)])
                      (apply-method
                       ; constructor method
                       (find-method class-name 'initialize)
                       obj
                       args
                       )
                      ; return newly created obj
                      obj
                      )
                    )
    (method-call-exp (obj-exp method-name rands)
                     (let ([args (value-of-exps rands env)] [obj (value-of-exp obj-exp env)])
                       (apply-method
                        (find-method (object->class-name obj) method-name)
                        obj
                        args
                        )
                       )
                     )
    (super-call-exp (method-name rands)
                    ; use surrounding self
                    (let ([args (value-of-exps rands env)] [obj (apply-nameless-env env self-index)])
                      (apply-method
                       ; find method in super class
                       (find-method (apply-nameless-env env super-index) method-name)
                       obj
                       args
                       )
                      )
                    )
    (nameless-self-exp () (apply-nameless-env env self-index))
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )

(define (value-of-exps exps env)
  (map (lambda (exp) (value-of-exp exp env)) exps)
  )
