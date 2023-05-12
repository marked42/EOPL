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
  (set! thread-id -1)
  (set! current-thread 'uninitialized)
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
  (a-thread (proc procedure?) (timeslice number?) (id number?) (parent number?))
  )

(define thread-id -1)

(define (next-thread-id)
  (set! thread-id (+ thread-id 1))
  thread-id
  )

(define (new-thread th timeslice)
  (let ((id (next-thread-id)) (parent (if (eq? current-thread 'uninitialized) -1 (thread->id current-thread))))
    (eopl:pretty-print (list "creating thread " id parent th timeslice))
    (a-thread th timeslice id parent)
    )
  )

(define current-thread 'unintialized)

(define (pause-current-thread new-proc)
  (cases my-thread current-thread
    (a-thread (proc timeslice id parent)
              (eopl:pretty-print (list "pause current thread " id parent new-proc))
              (a-thread new-proc timeslice id parent)
              )
    )
  )

(define (start-thread th)
  (eopl:pretty-print (list "start thread " th))
  (set! current-thread th)
  (cases my-thread th
    (a-thread (proc timeslice id parent)
              (set! the-time-remaining timeslice)
              (proc)
              )
    )
  )

(define (thread->id th)
  (cases my-thread th
    (a-thread (proc timeslice id parent)
              id
              )
    )
  )
