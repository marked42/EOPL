#lang eopl

(provide (all-defined-out))

(define (swapper s1 s2 slist)
  (if (null? slist)
      '()
      (let ((first (car slist)) (rest (cdr slist)))
        (define replaced
          (cond ((eq? first s1) s2)
                ((eq? first s2) s1)
                ; replace deeply
                ((list? first) (swapper s1 s2 first))
                (else first)
                )
          )

        (cons replaced (swapper s1 s2 rest))
        )
      )
  )
