#lang eopl

(require "test.rkt")

(define (subst new old slist)
  (subst/k new old slist (end-cont))
  )

(define (subst/k new old slist cont)
  (if (symbol? slist)
      (apply-cont cont
                  (if (eqv? old slist)
                      new
                      slist
                      )
                  )
      (if (null? slist)
          (apply-cont cont '())
          (let ((first (car slist)) (rest (cdr slist)))
            (subst/k new old first (subst1-cont new old rest cont))
            )
          )
      )
  )

(define (slist? val)
  (or
   (symbol? val)
   (list? val)
   )
  )

(define-datatype continuation cont?
  (end-cont)
  (subst1-cont (new symbol?) (old symbol?) (slist slist?) (saved-cont cont?))
  (subst2-cont (first slist?) (saved-cont cont?))
  )

(define (apply-cont cont val)
  (cases continuation cont
    (end-cont ()
              (begin
                (eopl:printf "End of computation.~%")
                (eopl:printf "This sentence should appear only once.~%")
                val
                )
              )
    (subst1-cont (new old slist saved-cont)
                 (subst/k new old slist (subst2-cont val saved-cont))
                 )
    (subst2-cont (first saved-cont)
                 (apply-cont saved-cont (cons first val))
                 )
    )
  )

(test-subst subst)
