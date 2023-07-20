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
    (interface ("(" "(" (arbno identifier ":" interface) ")" "=>" interface ")") proc-interface)

    (declaration (identifier ":" type) var-declaration)
    (declaration ("opaque" identifier) opaque-type-declaration)
    (declaration ("transparent" identifier "=" type) transparent-type-declaration)

    (module-body ("[" (arbno definition) "]") definitions-module-body)
    (module-body ("module-proc" "("(separated-list proc-module-param ",")")" module-body) proc-module-body)
    (module-body (identifier) var-module-body)
    (module-body ("("identifier (arbno identifier)")") app-module-body)

    (proc-module-param (identifier ":" interface) typed-proc-module-param)

    (definition (identifier "=" expression) val-definition)
    (definition ("type" identifier "=" type) type-definition)

    (expression ("from" identifier "take" identifier) qualified-var-exp)

    (expression (number) const-exp)
    (expression (identifier) var-exp)

    (expression ("-" "(" expression "," expression ")") diff-exp)
    (expression ("zero?" "(" expression ")") zero?-exp)

    (expression ("if" expression "then" expression "else" expression) if-exp)

    (expression ("let" identifier "=" expression "in" expression) let-exp)

    (expression ("proc" "(" identifier ":" type")" expression) proc-exp)
    (expression ("("expression expression")" ) call-exp)

    (expression ("letrec" type identifier "(" identifier ":" type ")" "=" expression "in" expression) letrec-exp)

    (type ("int") int-type)
    (type ("bool") bool-type)
    (type ("(" type "->" type")") proc-type)

    (type (identifier) named-type)
    (type ("from" identifier "take" identifier) qualified-type)
    )
  )

(define scan&parse (sllgen:make-string-parser the-lexical-spec the-grammar))
