#lang eopl

(require racket/lazy-require racket/list "../expression.rkt")

(lazy-require
 ["type.rkt" (type? proc-type check-is-subtype! class-type)]
 ["type-environment.rkt" (extend-tenv* init-tenv extend-tenv-with-self-and-super)]
 ["../maybe.rkt" (maybe)]
 ["main.rkt" (type-of)]
 )

(provide (all-defined-out))

(define method-tenv? (list-of (lambda (p) (and (pair? p)
                                               (symbol? (car p))
                                               (type? (cadr p))
                                               ))))

(define-datatype static-class static-class?
  (a-static-class
   (super-name (maybe symbol?))
   (interface-names (list-of symbol?))
   (field-names (list-of symbol?))
   (field-types (list-of type?))
   (method-tenv method-tenv?)
   )
  (an-interface
   (method-tenv method-tenv?)
   )
  )

(define (static-class->super-name class)
  (cases static-class class
    (a-static-class (super-name interface-names field-names field-types method-tenv)
                    super-name
                    )
    (an-interface (method-tenv)
                  (eopl:error 'static-class->super-name "Expect a-static-class, get an-interface ~s" class)
                  )
    )
  )

(define (static-class->interface-names class)
  (cases static-class class
    (a-static-class (super-name interface-names field-names field-types method-tenv)
                    interface-names
                    )
    (an-interface (method-tenv)
                  (eopl:error 'static-class->interface-names "Expect a-static-class, get an-interface ~s" class)
                  )
    )
  )

(define (static-class->field-names class)
  (cases static-class class
    (a-static-class (super-name interface-names field-names field-types method-tenv)
                    field-names
                    )
    (an-interface (method-tenv)
                  (eopl:error 'static-class->field-names "Expect a-static-class, get an-interface ~s" class)
                  )
    )
  )

(define (static-class->field-types class)
  (cases static-class class
    (a-static-class (super-name interface-names field-names field-types method-tenv)
                    field-types
                    )
    (an-interface (method-tenv)
                  (eopl:error 'static-class->field-types "Expect a-static-class, get an-interface ~s" class)
                  )
    )
  )

(define (static-class->method-tenv class)
  (cases static-class class
    (a-static-class (super-name interface-names field-names field-types method-tenv)
                    method-tenv
                    )
    (an-interface (method-tenv)
                  method-tenv
                  )
    )
  )

(define (initialize-static-class-env! class-decls)
  (empty-the-static-class-env!)
  (add-static-class-binding! 'object (a-static-class #f '() '() '() '()))
  (for-each add-class-decl-to-static-env! class-decls)
  )

(define the-static-class-env 'uninitialized)

(define (empty-the-static-class-env!)
  (set! the-static-class-env '())
  )

(define (add-static-class-binding! class-name static-class)
  (set! the-static-class-env
        (cons (list class-name static-class) the-static-class-env)
        )
  )

(define (add-class-decl-to-static-env! c-decl)
  (cases class-decl c-decl
    (a-class-decl (c-name s-name interface-names f-types f-names f-exps m-decls)
                  (let* ([static-class (lookup-static-class s-name)]
                         [i-names (append (static-class->interface-names static-class) interface-names)]
                         [f-names (append-field-names (static-class->field-names static-class) f-names)]
                         [f-types (append (static-class->field-types static-class) f-types)]
                         [method-tenv (let ([local-method-tenv (method-decls->method-tenv m-decls)])
                                        (check-no-dups! (map car local-method-tenv) c-name)
                                        (merge-method-tenvs (static-class->method-tenv static-class) local-method-tenv)
                                        )]
                         )
                    (check-no-dups! i-names c-name)
                    (check-no-dups! f-names c-name)
                    (check-for-initialize! method-tenv c-name)
                    (add-static-class-binding!
                     c-name
                     (a-static-class s-name i-names f-names f-types method-tenv)
                     )
                    )
                  )
    (an-interface-decl (name abstract-m-decls)
                       (let ([m-tenv (abs-method-decls->method-tenv abstract-m-decls)])
                         (check-no-dups! (map car m-tenv) name)
                         (add-static-class-binding! name (an-interface m-tenv))
                         )
                       )
    )
  )

(define (check-for-initialize! method-tenv c-name)
  (when (not (maybe-find-method-type method-tenv 'initialize))
    (eopl:error 'check-for-initialize! "no initialize method in class ~s" c-name)
    )
  )

(define (append-field-names super-fields new-fields)
  (if (null? super-fields)
      new-fields
      (let ([first-super-field (car super-fields)] [rest-super-fields (cdr super-fields)])
        (cons
         (if (memq first-super-field new-fields)
             (fresh-identifier first-super-field)
             first-super-field
             )
         (append-field-names rest-super-fields new-fields)
         )
        )
      )
  )

(define sn 0)
(define (fresh-identifier field)
  (set! sn (+ sn 1))
  (string->symbol
   (string-append
    (symbol->string field)
    "%"             ; this can't appear in an input identifier
    (number->string sn)))
  )

(define (method-decls->method-tenv m-decls)
  (map (lambda (m-decl)
         (cases method-decl m-decl
           (a-method-decl (result-type method-name vars var-types body)
                          (list method-name (proc-type var-types result-type))
                          )
           (an-abstract-method-decl (result-type method-name vars var-types)
                                    (eopl:error 'method-decls->method-tenv "Expect method decl, get ~s." m-decl)
                                    )
           )) m-decls)
  )

(define (abs-method-decls->method-tenv abs-m-decls)
  (map (lambda (m-decl)
         (cases method-decl m-decl
           (a-method-decl (result-type method-name vars var-types body)
                          (eopl:error 'abs-method-decls->method-tenv "Expect abstract method decl, get ~s." m-decl)
                          )
           (an-abstract-method-decl (result-type method-name vars var-types)
                                    (list method-name (proc-type var-types result-type))
                                    )
           )) abs-m-decls)
  )

(define (merge-method-tenvs super-m-tenv new-m-tenv)
  (append new-m-tenv super-m-tenv)
  )

(define (check-class-decl! c-decl)
  (cases class-decl c-decl
    (an-interface-decl (i-name abs-method-decls)
                       #t
                       )
    (a-class-decl (class-name super-name i-names field-types field-names field-exps method-decls)
                  (let ([sc (lookup-static-class class-name)])
                    (for-each
                     (lambda (m-decl)
                       (check-method-decl! m-decl class-name super-name
                                           (static-class->field-names sc)
                                           (static-class->field-types sc)
                                           )
                       )
                     method-decls
                     )
                    (for-each check-field-decl! field-types field-exps)
                    )
                  (for-each
                   (lambda (i-name) (check-if-implements! class-name i-name))
                   i-names
                   )
                  )
    )
  )

(define (check-field-decl! field-type field-exp)
  (let ([field-exp-type (type-of field-exp (init-tenv))])
    (check-is-subtype! field-exp-type field-type field-exp)
    )
  )

(define (check-method-decl! m-decl class-name super-name field-names field-types)
  (cases method-decl m-decl
    (a-method-decl (res-type m-name vars var-types body)
                   (let* ([tenv1 (extend-tenv* field-names field-types (init-tenv))]
                          [tenv2 (extend-tenv-with-self-and-super (class-type class-name) super-name tenv1)]
                          [tenv3 (extend-tenv* vars var-types tenv2)]
                          [body-type (type-of body tenv3)])
                     (check-is-subtype! body-type res-type m-decl)
                     (if (eqv? m-name 'initialize)
                         ; pass check fot initialize
                         #t
                         (let ([maybe-super-type (maybe-find-method-type (static-class->method-tenv (lookup-static-class super-name)) m-name)])
                           ; check if method type is compatible with parent method type
                           (if maybe-super-type
                               (check-is-subtype!
                                (proc-type var-types res-type)
                                maybe-super-type
                                m-decl
                                )
                               ; pass check for non-overriden method
                               #t
                               )
                           )
                         )
                     )
                   )
    (an-abstract-method-decl (res-type method-name vars var-types)
                             (eopl:error 'check-method-decl "Expect a-method-decl, get ~s" m-decl)
                             )
    )
  )

(define (check-if-implements! c-name i-name)
  (cases static-class (lookup-static-class i-name)
    (a-static-class (s-name i-names f-names f-types m-tenv)
                    (report-cant-implement-non-interface c-name i-name)
                    )
    (an-interface (method-tenv)
                  (let ([class-method-tenv (static-class->method-tenv (lookup-static-class c-name))])
                    (for-each
                     (lambda (method-binding)
                       (let* ([m-name (car method-binding)]
                              [m-type (cadr method-binding)]
                              [c-method-type (maybe-find-method-type class-method-tenv m-name)])
                         (if c-method-type
                             (check-is-subtype! c-method-type m-type c-name)
                             (report-missing-method c-name i-name m-name)
                             )
                         )
                       )
                     method-tenv
                     )
                    )
                  )
    )
  )

(define (report-cant-implement-non-interface c-name i-name)
  (eopl:error 'check-if-implements "class ~s claims to implement non-interface ~s" c-name i-name)
  )

(define (report-missing-method c-name i-name m-name)
  (eopl:error 'check-if-implements "class ~s claims to implement ~s, missing method ~s" c-name i-name m-name)
  )

(define (statically-is-subclass? name1 name2)
  (or
   (eqv? name1 name2)
   (let ([super-name (static-class->super-name (lookup-static-class name1))])
     (if super-name
         (statically-is-subclass? super-name name2)
         #f
         )
     )
   (let ([interface-names (static-class->interface-names (lookup-static-class name1))])
     (memv name2 interface-names)
     )
   )
  )

; 1. true when name1 is subclass of name2 or name2 is subclass of name1
; 2. true when name1 is a class which implements interface name2
; 3. true when name2 is a class which implements interface name1
; 4. error when name1/name2 both is interface, current language doesn't support inheritance between interfaces,
; so we don't handle this case.
(define (statically-is-instanceofable? name1 name2)
  (cases static-class (lookup-static-class name1)
    (a-static-class (super-name interface-names field-names field-types method-tenv)
                    (or
                     (statically-is-subclass? name1 name2)
                     (statically-is-subclass? name2 name1)
                     )
                    )
    (an-interface (method-tenv)
                  (cases static-class (lookup-static-class name2)
                    (a-static-class (super-name interface-names field-names field-types method-tenv)
                                    (statically-is-subclass? name2 name1)
                                    )
                    (an-interface (method-tenv)
                                  (eopl:error 'statically-is-compatible? "type ~s is not compatible with type ~s" name1 name2)
                                  )
                    )
                  )
    )
  )

(define (lookup-static-class name)
  (let ([maybe-pair (assq name the-static-class-env)])
    (if maybe-pair
        (second maybe-pair)
        (report-unknown-class-name name)
        )
    )
  )

(define (report-unknown-class-name name)
  (eopl:error 'lookup-static-class "Unknown class name ~s" name)
  )


(define (maybe-find-method-type tenv id)
  (cond
    ([assq id tenv] => cadr)
    (else #f)
    )
  )

(define (find-method-type class-name id)
  (let ([m (maybe-find-method-type (static-class->method-tenv (lookup-static-class class-name)) id)])
    (if m
        m
        (eopl:error 'find-method-type "unknown method ~s in class ~s" id class-name)
        )
    )
  )

(define (check-no-dups! lst blamee)
  (let loop ([rest lst])
    (cond
      ([null? rest] #t)
      ((memv (car rest) (cdr rest))
       (eopl:error 'check-no-dups! "duplicate found among ~s in class ~s" lst blamee)
       )
      (else (loop (cdr rest)))
      )
    )
  )
