#lang eopl

(require "test.rkt")

(define (subst new old slist)
  (subst/k new old slist
           (lambda (val)
             (eopl:printf "End of computation.~%")
             (eopl:printf "This sentence should appear only once.~%")
             val
             )
           )
  )

(define (subst/k new old slist cont)
  (if (symbol? slist)
      (cont (if (eqv? old slist)
                new
                slist
                )
            )
      (if (null? slist)
          (cont '())
          (let ((first (car slist)) (rest (cdr slist)))
            (subst/k new old first
                     (lambda (first-val)
                       (subst/k new old rest
                                (lambda (rest-val)
                                  (cont (cons first-val rest-val))
                                  ))
                       ))
            )
          )
      )
  )

(test-subst subst)
