#lang eopl

(require "the-lexical-spec.rkt")
(require "grammar.rkt")
; FIXME: sllgen:make-string-parser 隐式的依赖了a-program，必须引入expression.rkt
(require "expression.rkt")
(provide (all-defined-out))

(define scan&parse
  (sllgen:make-string-parser the-lexical-spec the-grammar))
