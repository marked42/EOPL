#lang eopl

(require "test.rkt")

(define (subst new old slist)
  (if (symbol? slist)
      (if (eqv? old slist)
          new
          slist
          )
      (if (null? slist)
          '()
          (let ((first (car slist)) (rest (cdr slist)))
            (cons
             (subst new old first)
             (subst new old rest)
             )
            )
          )
      )
  )

(test-subst subst)
