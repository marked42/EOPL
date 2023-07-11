#lang eopl

(require "expression.rkt" "module.rkt")
(require "checker/type.rkt")
(provide (all-defined-out))

(define the-lexical-spec
  '((whitespace (whitespace) skip)
    (comment ("%" (arbno (not #\newline))) skip)
    (identifier
     (letter (arbno (or letter digit "_" "-" "?")))
     symbol)
    (number (digit (arbno digit)) number)
    (number ("-" digit (arbno digit)) number)
    ))

(define the-grammar
  '((program ((arbno module-definition) expression) a-program)

    (module-definition ("module" identifier "interface" interface "body" module-body) a-module-definition)

    (interface ("[" (arbno declaration)"]") simple-interface)
    (declaration (identifier ":" type) var-declaration)

    (module-body ("[" (arbno definition) "]") definitions-module-body)
    (module-body ("letrec"(arbno type identifier "(" identifier ":" type ")" "=" expression) "in" "[" (arbno definition) "]") letrec-module-body)

    (definition (identifier "=" expression) val-definition)

    (expression ("from" identifier "take" identifier) qualified-var-exp)

    (expression (number) const-exp)
    (expression (identifier) var-exp)

    (expression ("#t") true-exp)
    (expression ("#f") false-exp)

    (expression ("-" "(" expression "," expression ")") diff-exp)
    (expression ("zero?" "(" expression ")") zero?-exp)

    (expression ("if" expression "then" expression "else" expression) if-exp)

    (expression ("let" (arbno identifier "=" expression) "in" expression) let-exp)

    (expression ("proc" "(" (separated-list paramter ",") ")" expression) proc-exp)
    (expression ("("expression (arbno expression)")" ) call-exp)

    (parameter (identifier ":" type) typed-parameter)

    (expression ("letrec" (arbno type identifier "(" identifier ":" type ")" "=" expression) "in" expression) letrec-exp)

    (type ("int") int-type)
    (type ("bool") bool-type)
    (type ("(" (arbno type) "->" type")") proc-type)
    )
  )

(define scan&parse (sllgen:make-string-parser the-lexical-spec the-grammar))
