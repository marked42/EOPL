#lang eopl

(provide (all-defined-out))

(define (equal-type? ty1 ty2)
  (equal-up-to-gensyms? ty1 ty2)
  )

(define (tvar-type-sym? sym)
  (and
   (symbol? sym)
   (char-numeric? (car (reverse (symbol->char-list sym))))
   )
  )

(define (symbol->char-list x)
  (string->list (symbol->string x))
  )

(define (equal-up-to-gensyms? sexp1 sexp2)
  (equal?
   (apply-subst-to-sexp (canonical-subst sexp1) sexp1)
   (apply-subst-to-sexp (canonical-subst sexp2) sexp2)
   )
  )

(define (canonical-subst sexp)
  (let loop ([sexp sexp] [table '()])
    (cond
      [(null? sexp) table]
      [(tvar-type-sym? sexp)
       (cond
         [(assq sexp table) table]
         [else
          (cons (cons sexp (counter->tvar-symbol (length table))) table)
          ]
         )
       ]
      [(pair? sexp)
       (loop (cdr sexp) (loop (car sexp) table))
       ]
      [else table]
      )
    )
  )

(define (apply-subst-to-sexp subst sexp)
  (cond
    [(null? sexp) sexp]
    [(tvar-type-sym? sexp)
     (cdr (assq sexp subst))
     ]
    [(pair? sexp)
     (cons
      (apply-subst-to-sexp subst (car sexp))
      (apply-subst-to-sexp subst (cdr sexp))
      )
     ]
    [else sexp]
    )
  )

(define (counter->tvar-symbol n)
  (string->symbol (string-append "tvar" (number->string n)))
  )
