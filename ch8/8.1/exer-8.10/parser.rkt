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
  '((program ((arbno module-definition) import-declaration expression) a-program)

    (module-definition ("module" identifier "interface" interface "body" module-body) a-module-definition)

    (interface ("[" (arbno declaration)"]") simple-interface)
    (declaration (identifier ":" type) var-declaration)

    (module-body (import-declaration "[" (arbno definition) "]") definitions-module-body)
    (definition (identifier "=" expression) val-definition)

    (import-declaration () empty-import-declaration)

    (expression ("from" identifier "take" identifier) qualified-var-exp)

    (expression (number) const-exp)
    (expression (identifier) var-exp)

    (expression ("-" "(" expression "," expression ")") diff-exp)
    (expression ("zero?" "(" expression ")") zero?-exp)

    (expression ("print" "(" expression ")") print-exp)

    (expression ("if" expression "then" expression "else" expression) if-exp)

    (expression ("let" identifier "=" expression "in" expression) let-exp)

    (expression ("proc" "(" identifier ":" type")" expression) proc-exp)
    (expression ("("expression expression")" ) call-exp)

    (expression ("letrec" type identifier "(" identifier ":" type ")" "=" expression "in" expression) letrec-exp)


    (type ("int") int-type)
    (type ("bool") bool-type)
    (type ("(" type "->" type")") proc-type)
    )
  )

(define scan&parse (sllgen:make-string-parser the-lexical-spec the-grammar))
