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

(define (end-cont)
  (lambda (val)
    (eopl:printf "End of computation.~%")
    (eopl:printf "This sentence should appear only once.~%")
    val
    )
  )

(define (subst1-cont new old slist saved-cont)
  (lambda (val)
    (subst/k new old slist (subst2-cont val saved-cont))
    )
  )

(define (subst2-cont first saved-cont)
  (lambda (val)
    (apply-cont saved-cont (cons first val))
    )
  )

(define (apply-cont cont val)
  (cont val)
  )

(test-subst subst)
