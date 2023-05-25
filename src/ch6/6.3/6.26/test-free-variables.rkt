#lang eopl

(require racket/lazy-require rackunit "../cps-lang/expression.rkt")
(lazy-require
 ["../cps-lang/formatter.rkt" (format-cps-exp)]
 ["parser.rkt" (scan&parse)]
 ["transformer.rkt" (cps-of-program replace-free-variables)]
 )

(provide (all-defined-out))

(define (test-replace-free-variables)
    (test-const-exp)
    (test-var-exp)
    (test-diff-exp)
    (test-zero?-exp)
    (test-proc-exp)
    (test-sum-exp)
    (test-list-exp)
    (test-let-exp)
    (test-letrec-exp)
    (test-if-exp)
    (test-call-exp)
)

(define (test-replace-base source target-var new-var expected message)
    (cases cps-program (scan&parse source)
        (cps-a-program (exp)
            (let ((new-simple-exp (cps-var-exp new-var)))
                (check-equal?
                    (format-cps-exp (replace-free-variables exp target-var new-simple-exp))
                    expected
                    message
                )
            )
        )
    )
)

(define (test-const-exp)
    (test-replace-base "1" 'a 'b "1" "const-exp")
)

(define (test-var-exp)
    (test-replace-base "a" 'a 'b "b" "var-exp")
    (test-replace-base "c" 'a 'b "c" "var-exp")
)

(define (test-diff-exp)
    (test-replace-base "-(a, a)"  'a 'b "-(b, b)" "diff-exp")
    (test-replace-base "-(c, c)"  'a 'b "-(c, c)" "diff-exp")
)

(define (test-zero?-exp)
    (test-replace-base "zero?(a)" 'a 'b "zero?(b)" "zero?-exp")
)

(define (test-proc-exp)
    (test-replace-base "proc (x) a" 'a 'b "proc (x) b" "proc-exp")
    (test-replace-base "proc (a) a" 'a 'b "proc (a) a" "proc-exp")
)

(define (test-sum-exp)
    (test-replace-base "+(a, b, a, d)" 'a 'b "+(b, b, b, d)" "sum-exp")
)

(define (test-list-exp)
    (test-replace-base "list(a, b, a, d)" 'a 'b "list(b, b, b, d)" "list-exp")
)

(define (test-let-exp)
    (test-replace-base "let c = 1 in a" 'a 'b "let c = 1 in b" "let-exp")
    (test-replace-base "let a = 1 in a" 'a 'b "let a = 1 in a" "let-exp")
)

(define (test-letrec-exp)
    (test-replace-base "letrec c(x) = x in a" 'a 'b "letrec c(x) = x in b" "letrec-exp")
    (test-replace-base "letrec a(x) = x in a" 'a 'b "letrec a(x) = x in a" "letrec-exp")

    (test-replace-base "letrec x(c) = a in x" 'a 'b "letrec x(c) = b in x" "letrec-exp")
    (test-replace-base "letrec x(a) = a in x" 'a 'b "letrec x(a) = a in x" "letrec-exp")
)

(define (test-if-exp)
    (test-replace-base "if a then a else a" 'a 'b "if b then b else b" "if-exp")
)

(define (test-call-exp)
    (test-replace-base "(a a a)" 'a 'b "(b b b)" "call-exp")
    (test-replace-base "(c c c)" 'a 'b "(c c c)" "call-exp")
)

(test-replace-free-variables)
