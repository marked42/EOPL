#lang eopl

(require racket/lazy-require)
(lazy-require
 ["queue.rkt" (enqueue dequeue empty-queue empty?)]
 )

(provide (all-defined-out))

(define the-ready-queue 'uninitialized)
(define the-final-answer 'uninitialized)
(define the-max-time-slice 'uninitialized)
(define the-time-remaining 'uninitialized)

(define (initialize-scheduler! ticks)
  (set! the-ready-queue (empty-queue))
  (set! the-final-answer 'uninitialized)
  (set! the-max-time-slice ticks)
  (set! the-time-remaining the-max-time-slice)
  )

(define (place-on-ready-queue! th use-remaining-time-slice)
  (if use-remaining-time-slice
    (set! the-ready-queue (enqueue the-ready-queue (cons th the-time-remaining)))
    (set! the-ready-queue (enqueue the-ready-queue (cons th the-max-time-slice)))
    )
  )

(define (run-next-thread)
  (if (empty? the-ready-queue)
      ; return final answer
      the-final-answer
      (dequeue the-ready-queue (lambda (head other-ready-threads)
                                 (set! the-ready-queue other-ready-threads)
                                 (let ((first-ready-thread (car head)) (time-slice (cdr head)))
                                    (set! the-time-remaining time-slice)
                                    (first-ready-thread)
                                  )
                                 ))
      )
  )

(define (set-final-answer! val)
  (set! the-final-answer val)
  )

(define (timer-expired?)
  (zero? the-time-remaining)
  )

(define (decrement-timer!)
  (set! the-time-remaining (- the-time-remaining 1))
  )
