#lang eopl

(require "test.rkt")

(define new 'uninitialized)
(define old 'uninitialized)
(define slist 'uninitialized)
(define cont 'uninitialized)
(define answer 'uninitialized)

(define (subst arg-new arg-old arg-slist)
  (set! new arg-new)
  (set! old arg-old)
  (set! slist arg-slist)
  (set! cont (end-cont))
  (subst/k)
  )

(define (subst/k)
  (if (symbol? slist)
      (begin
        (set! answer (if (eqv? old slist) new slist))
        (cont)
        )
      (if (null? slist)
          (begin
            (set! answer '())
            (cont)
            )
          (let ((first (car slist)) (rest (cdr slist)))
            (set! slist first)
            (set! cont (subst1-cont rest cont))
            (subst/k)
            )
          )
      )
  )

(define (end-cont)
  (lambda ()
    (eopl:printf "End of computation.~%")
    (eopl:printf "This sentence should appear only once.~%")
    answer
    )
  )

(define (subst1-cont rest saved-cont)
  (lambda ()
    (set! slist rest)
    (set! cont (subst2-cont answer saved-cont))
    (subst/k)
    )
  )

(define (subst2-cont first saved-cont)
  (lambda ()
    (set! answer (cons first answer))
    (set! cont saved-cont)
    (cont)
    )
  )

(test-subst subst)
