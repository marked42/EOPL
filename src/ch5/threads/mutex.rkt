#lang eopl

(require racket/lazy-require)
(lazy-require
 ["../shared/store.rkt" (reference? newref deref setref)]
 ["queue.rkt" (enqueue dequeue empty?)]
 ["threads.rkt" (place-on-ready-queue! pause-current-thread)]
 )

(provide (all-defined-out))

(define-datatype mutex mutex?
  (a-mutex
   (ref-to-closed? reference?)
   (ref-to-wait-queue reference?)
   )
  )

(define (new-mutex)
  (a-mutex (newref #f) (newref '()))
  )

(define (wait-for-mutex m th)
  (cases mutex m
    (a-mutex (ref-to-closed? ref-to-wait-queue)
             (cond
               ((deref ref-to-closed?)
                (setref ref-to-wait-queue (enqueue (deref ref-to-wait-queue) (pause-current-thread th)))
                )
               (else
                (setref ref-to-closed? #t)
                (th)
                )
               )
             )
    )
  )

(define (signal-mutex m)
  (cases mutex m
    (a-mutex (ref-to-closed? ref-to-wait-queue)
             (let ((closed? (deref ref-to-closed?)) (wait-queue (deref ref-to-wait-queue)))
               (if closed?
                   (if (empty? wait-queue)
                       (setref ref-to-closed? #f)
                       (dequeue wait-queue (lambda (first-waiting-thread other-waiting-threads)
                                             (place-on-ready-queue! first-waiting-thread #f)
                                             (setref ref-to-wait-queue other-waiting-threads)
                                             ))
                       )
                   ; placeholder
                   #f
                   )
               )
             )
    )
  )
