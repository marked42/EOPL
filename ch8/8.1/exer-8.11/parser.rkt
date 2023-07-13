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
    (definition (identifier "=" expression) val-definition)

    (expression ("from" identifier "take" identifier) qualified-var-exp)

    (expression (number) const-exp)
    (expression (identifier) var-exp)

    (expression ("-" "(" expression "," expression ")") diff-exp)
    (expression ("zero?" "(" expression ")") zero?-exp)

    (expression ("if" expression "then" expression "else" expression) if-exp)

    (expression ("let" identifier "=" expression "in" expression) let-exp)

    (expression ("proc" "(" identifier ":" optional-type")" expression) proc-exp)
    (expression ("("expression expression")" ) call-exp)

    (expression ("letrec" optional-type identifier "(" identifier ":" optional-type ")" "=" expression "in" expression) letrec-exp)

    (optional-type ("?") no-type)
    (optional-type (type) a-type)

    (type ("int") int-type)
    (type ("bool") bool-type)
    (type ("(" type "->" type")") proc-type)
    (type ("%tvar-type" number) tvar-type)
    )
  )

(define scan&parse (sllgen:make-string-parser the-lexical-spec the-grammar))
