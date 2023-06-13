#lang eopl

(require rackunit "main.rkt")

; (define number-tree
;   (interior-node 'foo
;                  (interior-node 'bar
;                                 (leaf 26)
;                                 (leaf 12))
;                  (interior-node 'baz
;                                 (leaf 11)
;                                 (interior-node 'quux
;                                                (leaf 117)
;                                                (leaf 14)
;                                                )
;                                 )
;                  )
;   )

; (define numbered-tree
;   '(foo (bar 0 1)
;         (baz 2 (quux 3 4))
;         )
;   )

; (check-equal? (number-leaves number-tree) numbered-tree "number leaves")
