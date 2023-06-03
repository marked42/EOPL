#lang racket/base

(require rackunit "ch1.rkt")
(check-equal? (in-S? 0) #t "0 in S")

(check-equal? (number-elements '(v0 v1 v2)) '((0 v0) (1 v1) (2 v2)) "number list elements")

; '#(2 2 2)
(check-eq? (vector-sum (make-vector 3 2)) 6 "list length should be 6")

; exer 1.15
(check-equal? (duple 2 3) '(3 3) "should return (1 1 1)")
(check-equal? (duple 4 '(ha ha)) '((ha ha) (ha ha) (ha ha) (ha ha)) "should return ((ha ha) (ha ha) (ha ha) (ha ha))")
(check-equal? (duple 0 '(blah)) '() "should return empty list")

; exer 1.16
(check-equal? (invert '((a 1) (a 2) (1 b) (2 b))) '((1 a) (2 a) (b 1) (b 2)) "should invert elements")

; exer 1.17
(check-equal? (down '(1 2 3)) '((1) (2) (3)) "should wrap top element with parenthesis")
(check-equal? (down '((a) (fine) (idea))) '(((a)) ((fine)) ((idea))) "should wrap top element with parenthesis")
(check-equal? (down '(a (more (complicated)) object)) '((a) ((more (complicated))) (object)) "should wrap top element with parenthesis")

; exer 1.18
(check-equal? (swapper 'a 'd '(a b c d)) '(d b c a) "swap a and d")
(check-equal? (swapper 'a 'd '(a d () c d)) '(d a () c a) "swap a and d")
(check-equal? (swapper 'x 'y '((x) y (z (x)))) '((y) x (z (y))) "swap x and y deeply")

; exer 1.19
(check-equal? (list-set '(a b c d) 2 '(1 2)) '(a b (1 2) d) "set 2nd element to (1 2)")
(check-equal? (list-ref (list-set '(a b c d) 3 '(1 5 10)) 3) '(1 5 10) "set 3rd element to (1 5 10)")

; exer 1.20
(check-equal? (count-occurrences 'x '((f x) y (((x z) x)))) 3 "count x")
(check-equal? (count-occurrences 'x '((f x) y (((x z) () x)))) 3 "count x")
(check-equal? (count-occurrences 'w '((f x) y (((x z) () x)))) 0 "count w")

; exer 1.21
(check-equal? (product '(a b c) '(x y)) '((a x) (a y) (b x) (b y) (c x) (c y)) "cartesian product")

; exer 1.22
(check-equal? (filter-in number? '(a 2 (1 3) b 7)) '(2 7) "filter in numbers")
(check-equal? (filter-in symbol? '(a (b c) 17 foo)) '(a foo) "filter in symbols")

; exer 1.23
(check-equal? (list-index number? '(a 2 (1 3) b 7)) 1 "first number at 1")
(check-equal? (list-index symbol? '(a (b c) 17 foo)) 0 "first symbol at 0")
(check-equal? (list-index symbol? '(1 2 (a b) 3)) #f "no symbols found")

; exer 1.24
(check-equal? (every? number? '(a b c 3 e)) #f "should be false")
(check-equal? (every? number? '(1 2 3 5 4)) #t "should be true")

; exer 1.25
(check-equal? (exists? number? '(a b c 3 e)) #t "should be true")
(check-equal? (exists? number? '(a b c d e)) #f "should be false")

; exer 1.26
(check-equal? (up '((1 2) (3 4))) '(1 2 3 4) "up")
(check-equal? (up '((x (y)) z)) '(x (y) z) "up")

; exer 1.27
(check-equal? (flatten '(a b c)) '(a b c) "flatten")
(check-equal? (flatten '((a) () (b ()) () (c))) '(a b c) "flatten")
(check-equal? (flatten '((a b) c (((d) e)))) '(a b c d e) "flatten")
(check-equal? (flatten '(a b (() (c)))) '(a b c) "flatten")

; exer 1.28
(check-equal? (merge '(1 4) '(1 2 8)) '(1 1 2 4 8) "merge")
(check-equal? (merge '(35 62 81 90 91) '(3 83 85 90)) '(3 35 62 81 83 85 90 90 91) "merge")

; exer 1.29
(check-equal? (sort '(8 2 5 2 3)) '(2 2 3 5 8) "sort in ascending order")

; exer 1.30
(check-equal? (sort/predicate < '(8 2 5 2 3)) '(2 2 3 5 8) "sort in ascending order")
(check-equal? (sort/predicate > '(8 2 5 2 3)) '(8 5 3 2 2) "sort in descending order")

; exer 1.31
(check-equal? (interior-node 'red (leaf 1) (leaf 2)) '(red 1 2) "build binary tree")

; exer 1.32
(check-equal? (double-tree (interior-node 'red (leaf 1) (leaf 2))) '(red 2 4) "double binary tree")

(define tree
  (interior-node 'red
                 (interior-node 'bar
                                (leaf 26)
                                (leaf 12))
                 (interior-node 'red
                                (leaf 11)
                                (interior-node 'quux
                                               (leaf 117)
                                               (leaf 14)))))
(define marked-tree
  (list 'red
        (list 'bar 1 1)
        (list 'red 2 (list 'quux 2 2))
        )
  )

; exer 1.33
(check-equal? (mark-leaves-with-red-depth tree) marked-tree "mark tree")

(define path-tree
  '(14 (7 () (12 () ()))
       (26 (20 (17 () ())
               ())
           (31 () ()))))

(check-equal? (path 17 path-tree) '(right left left) "return path")

; exer 1.35
(define number-tree
  (interior-node 'foo
                 (interior-node 'bar
                                (leaf 26)
                                (leaf 12))
                 (interior-node 'baz
                                (leaf 11)
                                (interior-node 'quux
                                               (leaf 117)
                                               (leaf 14)
                                               )
                                )
                 )
  )

(define numbered-tree
  '(foo (bar 0 1)
        (baz 2 (quux 3 4))
        )
  )

(check-equal? (number-leaves number-tree) numbered-tree "number leaves")

; exer 1.36
(check-equal? (number-elements-v2 '(v0 v1 v2)) '((0 v0) (1 v1) (2 v2)) "number list elements")
