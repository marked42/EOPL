#lang eopl

(require "expression.rkt" "modifier.rkt")
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
  '((program ((arbno class-decl) expression) a-program)
    (expression (number) const-exp)
    (expression (identifier) var-exp)

    (class-decl ("class" identifier "extends" identifier (arbno field-modifier identifier) (arbno method-decl)) a-class-decl)

    (field-modifier ("field") public-field)
    (field-modifier ("public-field") public-field)
    (field-modifier ("protected-field") protected-field)
    (field-modifier ("private-field") private-field)

    (method-decl (visibility-modifier "method" identifier "("(separated-list identifier ",")")" expression) a-method-decl)

    (expression ("fieldref" identifier) fieldref-exp)
    (expression ("fieldset" identifier "=" expression) fieldset-exp)

    (visibility-modifier () public-modifier)
    (visibility-modifier ("public") public-modifier)
    (visibility-modifier ("protected") protected-modifier)
    (visibility-modifier ("private") private-modifier)

    (expression ("-" "(" expression "," expression ")") diff-exp)
    (expression ("+" "(" expression "," expression ")") sum-exp)
    (expression ("zero?" "(" expression ")") zero?-exp)

    (expression ("if" expression "then" expression "else" expression) if-exp)

    (expression ("let" (arbno identifier "=" expression) "in" expression) let-exp)

    (expression ("proc" "(" (separated-list identifier ",") ")" expression) proc-exp)
    (expression ("("expression (arbno expression)")" ) call-exp)

    (expression ("letrec" (arbno identifier "(" identifier ")" "=" expression) "in" expression) letrec-exp)

    (expression ("begin" expression (arbno ";" expression) "end") begin-exp)

    (expression ("set" identifier "=" expression) assign-exp)

    (expression ("cons" "(" expression "," expression ")") cons-exp)
    (expression ("car" "(" expression ")") car-exp)
    (expression ("cdr" "(" expression ")") cdr-exp)
    (expression ("emptylist") emptylist-exp)
    (expression ("null?" "(" expression ")") null?-exp)
    (expression ("list" "("(separated-list expression ",")")") list-exp)

    (expression ("new" identifier "("(separated-list expression ",")")") new-object-exp)
    (expression ("send" expression identifier "("(separated-list expression ",")")") method-call-exp)
    (expression ("super" identifier "("(separated-list expression ",")")") super-call-exp)
    (expression ("self") self-exp)
    )
  )

(define scan&parse (sllgen:make-string-parser the-lexical-spec the-grammar))