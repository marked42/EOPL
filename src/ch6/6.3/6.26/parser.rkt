#lang eopl

(require "../cps-lang/cps-out-grammar.rkt")
(require "../../../base/the-lexical-spec.rkt")
; sllgen-make-string-parser uses expression types as output
(require "../cps-lang/expression.rkt")

(provide (all-defined-out))

(define scan&parse (sllgen:make-string-parser the-lexical-spec the-grammar))
