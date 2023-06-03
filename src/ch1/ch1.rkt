#lang racket/base

(provide (all-defined-out))

(define in-S?
  (lambda (n)
    (if (zero? n)
        #t
        (if (>= (- n 3) 0)
            (in-S? (- n 3))
            #f))))

(define (list-of-integer? l)
  (if (null? l)
      #t
      (if (pair? l)
          (and (number? (car l)) (list-of-integer? (cdr l)))
          #f
          )
      )
  )

(define (list-length l)
  (cond ((null? l) 0)
        ((pair? l) (+ 1 (list-length (cdr l))))
        (else (error "l must be list"))
        )
  )

(define (nth-element l n)
  (if (null? l)
      (error "nth-element list too short by ~s elements.~%" (+ n 1))
      (if (zero? n)
          (car l)
          (nth-element (cdr l) (- n 1))
          )
      )
  )

; exer 1.6
; car 直接使用在空lis上报错

(define (eopl:error message)
  (error message)
  )

; exer 1.7
(define (nth-element-v1 l n)
  (define (loop list index)
    (if (null? list)
        ; FIXME:
        (eopl:error "list ~s does not have ~s elements.~%" l n)
        (if (zero? index)
            (car list)
            (nth-element-v1 (cdr list) (- index 1))
            )
        )
    )
  (loop l n)
  )

(define (remove-first s los)
  (if (null? los)
      '()
      (let ((first (car los)) (rest (cdr los)))
        (if (eq? first s)
            rest
            (cons first (remove-first s rest))
            )
        )
      )
  )

; exer 1.8
; 得到出现第一个符号s右边的子序列

; exer 1.9 remove all occurrences
(define (remove s los)
  (if (null? los)
      '()
      (let ((first (car los)) (rest (cdr los)))
        (if (eq? first s)
            (remove s rest)
            (cons first (remove s rest))
            )
        )
      )
  )

; exer 1.10

(define (occurs-free? var exp)
  (cond ((symbol? exp) (eqv? var exp))
        ((eqv? (car exp) 'lambda)
         (and
          (not (eqv? var (caadr exp)))
          (occurs-free? var (caddr exp))))
        (else
         (occurs-free? var (car exp))
         (occurs-free? var (cadr exp)))))

; S-list ::=({S-exp}∗)
; S-exp::=Symbol | S-list
; mutually recursive structure following grammar patterns
(define (subst old new slist)
  (if (null? slist)
      '()
      (let ((first (car slist)) (rest (cdr slist)))
        (cons
         (subst-in-s-exp old new first)
         (subst old new rest)
         )
        )
      )
  )

(define (subst-in-s-exp old new exp)
  (if (symbol? exp)
      (if (eqv? exp old) new exp)
      (subst old new exp)
      )
  )

; exer 1.11 subst-in-exp递归调用subst，subst会减小问题规模

; exer 1.12 inline subst-in-s-exp
(define (subst-inline old new slist)
  (if (null? slist)
      '()
      (let ((first (car slist)) (rest (car slist)))
        (cons
         (if (symbol? first)
             (if (eqv? first old) new first)
             (subst old new first)
             )
         (subst old new rest)
         )
        )
      )
  )

; exer 1.13 使用map进行递归
(define (subst-map old new slist)
  (map
   (lambda (x)
     (if (symbol? x)
         (if (eqv? x old) new x)
         (subst-map x)
         )
     )
   slist))

; (v0 v1 v2 ...) -> ((0 v0) (1 v1) (2 v2) ...)
(define (number-elements-from l from)
  (if (null? l)
      '()
      (cons
       (list from (car l))
       (number-elements-from (cdr l) (+ from 1))
       )
      )
  )

(define (number-elements l)
  (number-elements-from l 0)
  )


(define (list-sum lst)
  (if (null? lst)
      0
      (+ (car lst)
         (list-sum (cdr lst))
         )
      )
  )

(define (vector-sum v)
  (partial-vector-sum v (vector-length v))
  )

(define (partial-vector-sum v length)
  (if (zero? length)
      0
      (let ((sub-list-length (- length 1)))
        (+
         (vector-ref v sub-list-length)
         (partial-vector-sum v sub-list-length)
         )
        )
      )
  )

; exer 1.14 prove true for empty vector, then prove true for n + 1 when assuming n is true

; exer 1.15
(define (duple n x)
  (if (zero? n)
      '()
      (cons x (duple (- n 1) x))
      )
  )


; exer 1.16
(define (invert lst)
  (if (null? lst)
      '()
      (let ((first (car lst)) (rest (cdr lst)))
        (cons
         (list (cadr first) (car first))
         (invert rest)
         )
        )
      )
  )

; exer 1.17
(define (down lst)
  (if (null? lst)
      '()
      (let ((first (car lst)) (rest (cdr lst)))
        (cons
         (list first)
         (down rest)
         )
        )
      )
  )

; exer 1.18
(define (swapper s1 s2 slist)
  (if (null? slist)
      '()
      (let ((first (car slist)) (rest (cdr slist)))
        (define replaced
          (cond ((eq? first s1) s2)
                ((eq? first s2) s1)
                ; replace deeply
                ((list? first) (swapper s1 s2 first))
                (else first)
                )
          )

        (cons replaced (swapper s1 s2 rest))
        )
      )
  )

; exer 1.19
(define (list-set lst n x)
  (if (null? lst)
      '()
      (let ((first (car lst)) (rest (cdr lst)))
        (cond ((< n 0) (error "index ~s too large" n))
              ((= n 0)
               (cons x rest)
               )
              (else (cons first (list-set rest (- n 1) x)))
              )
        )
      )
  )

; exer 1.20 use mutual recursion instead of local state
(define (count-occurrences s slist)
  (define (count-occurrences-list l)
    (if (null? l)
        0
        (let ((first (car l)) (rest (cdr l)))
          (+
           (count-occurrences-element first)
           (count-occurrences-list rest)
           )
          )
        )
    )

  (define (count-occurrences-element element)
    (cond ((list? element)
           (count-occurrences-list element))
          ((eq? element s) 1)
          (else 0)
          )

    )
  (count-occurrences-list slist)
  )

; exer 1.21 empty sos2 case in included implictly
(define (product sos1 sos2)
  (if (null? sos1)
      '()
      (let ((first (car sos1)) (rest (cdr sos1)))
        (append
         (map (lambda (s2) (list first s2)) sos2)
         (product rest sos2)
         )
        )
      )
  )

; exer 1.22
(define (filter-in pred lst)
  (if (null? lst)
      '()
      (let ((first (car lst)) (rest (cdr lst)))
        (if (pred first)
            (cons first (filter-in pred rest))
            (filter-in pred rest))
        )
      )
  )

; exer 1.23
(define (list-index pred lst)
  (if (null? lst)
      #f
      (let ((first (car lst)) (rest (cdr lst)))
        (if (pred first)
            0
            (let ((index (list-index pred rest)))
              (if (number? index)
                  (+ 1 index)
                  #f
                  )
              )
            )
        )
      )
  )

; exer 1.24
(define (every? pred lst)
  (if (null? lst)
      #t
      (let ((first (car lst)) (rest (cdr lst)))
        (if (pred first)
            (every? pred rest)
            #f
            )
        )
      )
  )

; exer 1.25
(define (exists? pred lst)
  (if (null? lst)
      #f
      (let ((first (car lst)) (rest (cdr lst)))
        (if (pred first)
            #t
            (exists? pred rest)
            )
        )
      )
  )

; exer 1.26
(define (up lst)
  (if (null? lst)
      '()
      (let ((first (car lst)) (rest (cdr lst)))
        (if (list? first)
            (append first (up rest))
            (cons first (up rest))
            )
        )
      )
  )

; exer 1.27
(define (flatten lst)
  (if (null? lst)
      '()
      (let ((first (car lst)) (rest (cdr lst)))
        (if (list? first)
            (append (flatten first) (flatten rest))
            (cons first (flatten rest))
            )
        )
      )
  )

; exer 1.28
(define (merge loi1 loi2)
  (cond ((null? loi1) loi2)
        ((null? loi2) loi1)
        (else
         (let ((f1 (car loi1))
               (r1 (cdr loi1))
               (f2 (car loi2))
               (r2 (cdr loi2)))
           (if (< f1 f2)
               (cons f1 (merge r1 loi2))
               (cons f2 (merge loi1 r2))
               )
           ))
        )
  )

; exer 1.29
(define (sort loi)
  (define (insert val loi)
    (if (null? loi)
        (list val)
        (let ((first (car loi)) (rest (cdr loi)))
          (if (< val first)
              (cons val loi)
              (cons first (insert val rest))
              )
          )
        )
    )

  (if (null? loi)
      '()
      (let ((first (car loi)) (rest (cdr loi)))
        (insert first (sort rest))
        )
      )
  )

; exer 1.30
(define (sort/predicate pred loi)
  (define (insert val loi)
    (if (null? loi)
        (list val)
        (let ((first (car loi)) (rest (cdr loi)))
          (if (pred val first)
              (cons val loi)
              (cons first (insert val rest))
              )
          )
        )
    )

  (if (null? loi)
      '()
      (let ((first (car loi)) (rest (cdr loi)))
        (insert first (sort/predicate pred rest))
        )
      )
  )

; Bintree::=Int |(Symbol Bintree Bintree)
; exer 1.31
(define (leaf? node) (number? node))
(define (leaf node)
  (if (leaf? node)
      node
      (error "leaf accepts only number, get ~s." node)
      )
  )
(define (interior-node s left right) (list s left right))
(define (lson n)
  (if (leaf? n)
      (error "lson accetps only interior node, get leaf ~s" n)
      (cadr n)
      )
  )
(define (rson n)
  (if (leaf? n)
      (error "rson accetps only interior node, get leaf ~s" n)
      (caddr n)
      )
  )

(define (contents-of n)
  (if (leaf? n)
      n
      (car n)
      )
  )

; exer 1.32
(define (double-tree tree)
  (if (leaf? tree)
      (leaf (* 2 (contents-of tree)))
      (let ((content (contents-of tree)) (left (lson tree)) (right (rson tree)))
        (interior-node
         content
         (double-tree (leaf left))
         (double-tree (leaf right))
         )
        )
      )
  )

; exer 1.33
(define (mark-leaves-with-red-depth tree)
  (define (helper t depth)
    (if (leaf? t)
        (leaf depth)
        (let ((content (contents-of t)) (left (lson t)) (right (rson t)))
          (interior-node
           content
           (helper left (+ depth (if (eq? content 'red) 1 0)))
           (helper right (+ depth (if (eq? content 'red) 1 0)))
           )
          )
        )
    )
  (helper tree 0)
  )

; exer 1.34
(define (path n bst)
  (if (null? bst)
      '()
      (let ((content (contents-of bst)) (left (lson bst)) (right (rson bst)))
        (cond ((< n content)
               (cons 'left (path n left)))
              ((> n content)
               (cons 'right (path n right)))
              (else '())
              )
        )
      )
  )

; exer 1.35
(define (number-leaves tree)
  (define index -1)

  (define (traverse node)
    (if (leaf? node)
        (begin
          (set! index (+ index 1))
          (leaf index)
          )
        (let ((content (contents-of node)) (left (lson node)) (right (rson node)))
          (interior-node
           content
           (traverse left)
           (traverse right)
           )
          )
        )
    )

  (traverse tree)
  )

; exer 1.36
(define (number-elements-v2 lst)
  (if (null? lst)
      '()
      (g (list 0 (car lst)) (number-elements (cdr lst)))
      )
  )

(define (g first rest)
  (cons first
        (map (lambda (e) (list (+ (car e) 1) (cadr e))) rest)
        )
  )
