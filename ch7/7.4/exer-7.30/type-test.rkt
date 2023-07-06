#lang eopl

(require racket racket/list rackunit)
(require "inferrer/type.rkt")

(provide test-generic-type)

(define (test-free-vars)
  (check-equal? (free-vars (int-type)) '() "int-type")
  (check-equal? (free-vars (bool-type)) '() "bool-type")
  (check-equal? (free-vars (tvar-type 1)) (list (tvar-type 1)) "tvar-type")
  (check-equal? (free-vars (proc-type (int-type) (tvar-type 1))) (list (tvar-type 1)) "proc-type")
  (check-equal? (free-vars (proc-type (int-type) (proc-type (tvar-type 1) (tvar-type 2)))) (list (tvar-type 1) (tvar-type 2)) "nested proc-type")
  (check-equal? (free-vars (generic-type (proc-type (int-type) (tvar-type 1)) (list (tvar-type 1)))) '() "generic-type")
  )

(define (test-generalize)
  (check-equal? (generalize (int-type)) (int-type) "int-type")
  (check-equal? (generalize (bool-type)) (bool-type) "bool-type")
  (check-equal? (generalize (tvar-type 1)) (tvar-type 1) "tvar-type")
  (check-equal? (generalize (proc-type (int-type) (tvar-type 1))) (generic-type (proc-type (int-type) (tvar-type 1)) (list (tvar-type 1))) "proc-type -> generic-type")
  (check-equal? (generalize (proc-type (int-type) (proc-type (tvar-type 1) (tvar-type 2)))) (generic-type (proc-type (int-type) (proc-type (tvar-type 1) (tvar-type 2))) (list (tvar-type 1) (tvar-type 2))) "nested proc-type -> generic-type")
  (check-equal?
   (generalize (generic-type (proc-type (int-type) (tvar-type 1)) (list (tvar-type 1))))
   (generic-type (proc-type (int-type) (tvar-type 1)) (list (tvar-type 1)))
   "generic-type")
  )

(define (test-instantiate-type)
  (reset-fresh-var)

  (check-equal?
   (instantiate-type (generic-type (proc-type (int-type) (tvar-type 3)) (list (tvar-type 3))))
   (proc-type (int-type) (tvar-type 1))
   "generic-type"
   )
  )

(define (test-generic-type)
  (test-free-vars)
  (test-instantiate-type)
  (test-generalize)
  )
