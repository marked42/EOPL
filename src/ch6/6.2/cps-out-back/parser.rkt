#lang eopl

(require "the-lexical-spec.rkt")
(require "cps-out-grammar.rkt")
; sllgen-make-string-parser uses expression types as output
(require "expression.rkt")
(provide (all-defined-out))

(define scan&parse
  (sllgen:make-string-parser the-lexical-spec cps-out-grammar))
