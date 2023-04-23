#lang eopl

(require
  racket/lazy-require
  )
(lazy-require
 ["../shared/value.rkt" (expval?)]
 ["bounce-ds.rkt" (apply-bounce)]
 )

(provide (all-defined-out))

(define (trampoline bounce)
  (if (expval? bounce)
      bounce
      (let ((val (apply-bounce bounce)))
        (trampoline val)
        )
      )
  )
