#lang eopl

(require "fact-test.rkt")

(define n 'uninitialized)
(define cont 'uninitialized)
(define val 'uninitialized)
(define pc 'uninitialized)

(define (fact arg-n)
    (set! cont (end-cont))
    (set! n arg-n)
    (set! pc fact/k)
    (trampoline!)
    val
)

(define (end-cont)
    (lambda ()
        (set! pc #f)
    )
)

(define (fact/k)
    (if (zero? n)
        (begin
            (set! val 1)
            (set! pc apply-cont)
        )
        (begin
            (set! cont (fact1-cont n cont))
            (set! n (- n 1))
            (set! pc fact/k)
        )
    )
)

(define (fact1-cont saved-n saved-cont)
    (lambda ()
        (set! val (* val saved-n))
        (set! cont saved-cont)
        (set! pc apply-cont)
    )
)

(define (trampoline!)
    (if pc
        (begin
            (pc)
            (trampoline!)
        )
        #f
    )
)

(define (apply-cont)
    (cont)
)

(test-fact fact)
