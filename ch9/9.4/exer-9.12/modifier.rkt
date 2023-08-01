#lang eopl

(require racket/lazy-require)
(lazy-require
 ["environment.rkt" (find-caller-class-method)]
 ["method.rkt" (method->modifier)]
 ["class.rkt" (find-method is-sub-class find-field-class-modifier-pair)]
 ["object.rkt" (object->class-name)]
 )

(provide (all-defined-out))

(define-datatype visibility-modifier visibility-modifier?
  (public-modifier)
  (private-modifier)
  (protected-modifier)
  )

(define-datatype field-modifier field-modifier?
  (public-field)
  (private-field)
  (protected-field)
  )

(define (check-method-call-visibility class-name method-name env)
  (let* ([method (find-method class-name method-name)]
         [caller-class-method (find-caller-class-method env)]
         [modifier (method->modifier method)])
    (cases visibility-modifier modifier
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

(define (check-field-visibility obj field-name env)
  (let* ([p (find-field-class-modifier-pair (object->class-name obj) field-name)]
         [class-name (car p)]
         [f-modifier (cdr p)]
         [caller-class-method (find-caller-class-method env)]
         [caller-class-name (car caller-class-method)]
         [caller-method-name (cdr caller-class-method)])
    (cases field-modifier f-modifier
      (public-field () #t)
      (protected-field ()
                       (if (is-sub-class caller-class-name class-name)
                           #t
                           (eopl:error 'check-field-visibility "Proteced field ~s.~s accessed in ~s.~s, can only be accessed in class ~s or its descendants." class-name field-name caller-class-name caller-method-name class-name)
                       )
      )
      (private-field ()
        (if (eqv? class-name caller-class-name)
          #t
          (eopl:error 'check-field-visibility "Private field ~s.~s accessed in ~s.~s, can only accessed inside class ~s" class-name field-name caller-class-name caller-method-name class-name)
        )
      )
    )
  )
)
