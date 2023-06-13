#lang eopl

(provide (all-defined-out))

; (v0 v1 v2 ...) -> ((0 v0) (1 v1) (2 v2) ...)
(define (number-elements-from l from)
  (if (null? l)
      '()
      (cons
       (list from (car l))
       (number-elements-from (cdr l) (+ from 1))
       )
      )
  )

(define (number-elements l)
  (number-elements-from l 0)
  )

(define (g first rest)
  (cons first
        (map (lambda (e) (list (+ (car e) 1) (cadr e))) rest)
        )
  )

(define (number-elements-v2 lst)
  (if (null? lst)
      '()
      (g (list 0 (car lst)) (number-elements (cdr lst)))
      )
  )
