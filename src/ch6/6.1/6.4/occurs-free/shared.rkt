#lang eopl

(require racket/list)

(provide (all-defined-out))

; LcExp ::= Identifier
;       ::= (lambda (Identifier) LcExp)
;       ::=(LcExp LcExp)

(define (get-lambda-var exp)
  (first (second exp))
  )

(define (get-lambda-body exp)
  (third exp)
  )

(define (get-call-operator exp)
  (first exp)
  )

(define (get-call-operand exp)
  (second exp)
  )
