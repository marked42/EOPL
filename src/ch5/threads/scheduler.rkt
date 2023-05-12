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

(define (place-on-ready-queue! th)
  (set! the-ready-queue (enqueue the-ready-queue th))
  )

(define (run-next-thread)
  (if (empty? the-ready-queue)
      ; return final answer
      the-final-answer
      (dequeue the-ready-queue (lambda (head other-ready-threads)
                                 (set! the-ready-queue other-ready-threads)
                                 (start-thread head)
                                 ))
      )
  )

(define (set-final-answer! val)
  (set! the-final-answer val)
  )

(define (get-the-max-timeslice)
  the-max-time-slice
  )

(define (get-the-time-remaining)
  the-time-remaining
  )

(define (timer-expired?)
  (zero? the-time-remaining)
  )

(define (decrement-timer!)
  (set! the-time-remaining (- the-time-remaining 1))
  )

(define-datatype my-thread my-thread?
  (a-thread (proc procedure?) (timeslice number?))
  )

(define (new-thread th timeslice)
  (a-thread th timeslice)
  )

(define (start-thread th)
  (cases my-thread th
    (a-thread (proc timeslice)
              (set! the-time-remaining timeslice)
              (proc)
              )
    )
  )
