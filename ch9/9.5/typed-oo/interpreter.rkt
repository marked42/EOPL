#lang eopl

(require racket/lazy-require "parser.rkt" "expression.rkt")
(lazy-require
 ["environment.rkt" (
                     init-env
                     apply-env
                     extend-env*
                     extend-env-rec*
                     )]
 ["value.rkt" (num-val expval->num bool-val expval->bool proc-val expval->proc null-val null-val? cell-val cell-val->first cell-val->second)]
 ["procedure.rkt" (procedure apply-procedure)]
 ["store.rkt" (initialize-store! newref deref setref! show-store)]
 ["class.rkt" (initialize-class-env! find-method is-subclass?)]
 ["method.rkt" (apply-method)]
 ["object.rkt" (object->class-name new-object)]
 ["checker/main.rkt" (type-of-program)]
 )

(provide (all-defined-out))

(define (run str)
  (value-of-program (scan&parse str))
  )

(define (value-of-program prog)
  (type-of-program prog)
  ; new stuff
  (initialize-store!)
  (cases program prog
    (a-program (class-decls exp1)
               (initialize-class-env! class-decls)
               (value-of-exp exp1 (init-env))
               )
    )
  )

(define (value-of-exp exp env)
  (cases expression exp
    (const-exp (num) (num-val num))
    ; new stuff
    (var-exp (var) (deref (apply-env env var)))
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
    (let-exp (vars exps body)
             (let ([vals (value-of-exps exps env)])
               (value-of-exp body (extend-env* vars (map newref vals) env))
               )
             )
    (proc-exp (vars types body)
              (proc-val (procedure vars body env))
              )
    (call-exp (rator rands)
              (let ((rator-val (value-of-exp rator env)) (rand-vals (value-of-exps rands env)))
                (let ((proc1 (expval->proc rator-val)))
                  (apply-procedure proc1 rand-vals)
                  )
                )
              )
    (letrec-exp (p-result-types p-names b-vars-list b-var-types-list p-bodies body)
                (let ((new-env (extend-env-rec* p-names b-vars-list p-bodies env)))
                  (value-of-exp body new-env)
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
    (assign-exp (var exp1)
                (let ([val1 (value-of-exp exp1 env)])
                  (setref! (apply-env env var) val1)
                  )
                )
    ; list
    (emptylist-exp (element-type)
                   (null-val)
                   )
    (null?-exp (exp1)
               (let ([val1 (value-of-exp exp1 env)])
                 (bool-val (null-val? val1))
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
    (list-exp (exp1 exps)
              (let ([val1 (value-of-exp exp1 env)] [vals (value-of-exps exps env)])
                (let build-list ([vals (cons val1 vals)])
                  (if (null? vals)
                      (null-val)
                      (let ((first (car vals)) (rest (cdr vals)))
                        (cell-val first (build-list rest))
                        )
                      )
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
                    (let ([args (value-of-exps rands env)] [obj (apply-env env '%self)])
                      (apply-method
                       ; find method in super class
                       (find-method (apply-env env '%super) method-name)
                       obj
                       args
                       )
                      )
                    )
    (self-exp () (apply-env env '%self))

    (cast-exp (obj-exp class-name)
              (let ([obj (value-of-exp obj-exp env)])
                (if (is-subclass? (object->class-name obj) class-name)
                    obj
                    (report-cast-error class-name obj)
                    )
                )
              )
    (instanceof-exp (obj-exp class-name)
                    (let ([obj (value-of-exp obj-exp env)])
                      (if (is-subclass? (object->class-name obj) class-name)
                          (bool-val #t)
                          (bool-val #f)
                          )
                      )
                    )
    (else (eopl:error 'value-of-exp "unsupported expression type ~s" exp))
    )
  )

(define (value-of-exps exps env)
  (map (lambda (exp) (value-of-exp exp env)) exps)
  )

(define (report-cast-error class-name obj)
  (eopl:error 'report-cast-error "Object ~s is not an instance of ~s, cannot cast to ~s." obj class-name class-name)
  )
