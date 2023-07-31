#lang eopl

(require racket/lazy-require)
(lazy-require
 ["environment.rkt" (find-caller-class-method)]
 ["method.rkt" (method->modifier)]
 ["class.rkt" (find-method is-sub-class)]
 )

(provide (all-defined-out))

(define-datatype method-modifier method-modifier?
  (public-modifier)
  (private-modifier)
  (protected-modifier)
  )

(define (check-method-call-visibility class-name method-name env)
  (let* ([method (find-method class-name method-name)]
         [caller-class-method (find-caller-class-method env)]
         [modifier (method->modifier method)])
    (cases method-modifier modifier
      (public-modifier () #t)
      (protected-modifier ()
                          (if (not caller-class-method)
                              (eopl:error 'check-method-call-visibility "Protected method ~s.~s called in global environment, can only be called in ~s" class-name method-name class-name)
                              (let ([caller-class-name (car caller-class-method)] [caller-method-name (cdr caller-class-method)])
                                (if (is-sub-class caller-class-name class-name)
                                    #t
                                    (eopl:error 'check-method-call-visibility "Proteced method ~s.~s called in ~s.~s, can only be called in class ~s or its descendants." class-name method-name caller-class-name caller-method-name class-name)
                                    )
                                )
                              )
                          )
      (private-modifier ()
                        (if (not caller-class-method)
                            (eopl:error 'check-method-call-visibility "Private method ~s.~s called in global environment, can only be called in ~s" class-name method-name class-name)
                            (let ([caller-class-name (car caller-class-method)] [caller-method-name (cdr caller-class-method)])
                              (if (eqv? class-name caller-class-name)
                                  #t
                                  (eopl:error 'check-method-call-visibility "Private method ~s.~s called in ~s.~s, can only be called inside class ~s." class-name method-name caller-class-name caller-method-name class-name)
                                  )
                              )
                            )
                        )
      )
    )
  )
