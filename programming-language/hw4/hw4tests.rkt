#lang racket

(require "hw4.rkt") 

;; A simple library for displaying a 2x3 grid of pictures: used
;; for fun in the tests below (look for "Tests Start Here").

(require (lib "graphics.rkt" "graphics"))

(open-graphics)

(define window-name "Programming Languages, Homework 4")
(define window-width 700)
(define window-height 500)
(define border-size 100)

(define approx-pic-width 200)
(define approx-pic-height 200)
(define pic-grid-width 3)
(define pic-grid-height 2)

(define (open-window)
  (open-viewport window-name window-width window-height))

(define (grid-posn-to-posn grid-posn)
  (when (>= grid-posn (* pic-grid-height pic-grid-width))
    (error "picture grid does not have that many positions"))
  (let ([row (quotient grid-posn pic-grid-width)]
        [col (remainder grid-posn pic-grid-width)])
    (make-posn (+ border-size (* approx-pic-width col))
               (+ border-size (* approx-pic-height row)))))

(define (place-picture window filename grid-posn)
  (let ([posn (grid-posn-to-posn grid-posn)])
    ((clear-solid-rectangle window) posn approx-pic-width approx-pic-height)
    ((draw-pixmap window) filename posn)))

(define (place-repeatedly window pause stream n)
  (when (> n 0)
    (let* ([next (stream)]
           [filename (cdar next)]
           [grid-posn (caar next)]
           [stream (cdr next)])
      (place-picture window filename grid-posn)
      (sleep pause)
      (place-repeatedly window pause stream (- n 1)))))

;;(place-repeatedly (open-window) 1 (cons 5 "dan.jpg") 1000)
;; Tests Start Here

; These definitions will work only after you do some of the problems
; so you need to comment them out until you are ready.
; Add more tests as appropriate, of course.

(define nums (sequence 0 5 1))

;; test q1
nums
(sequence 3 11 2)
(sequence 3 8 3)
(sequence 3 2 1)

(define files (string-append-map 
               (list "dan" "dog" "curry" "dog2") 
               ".jpg"))

;; test q2
files

;; test q3
(list-nth-mod nums 1) ; == 1
(list-nth-mod nums 2) ; == 2
(list-nth-mod nums 6) ; == 0
(list-nth-mod nums 11) ; == 5
;(list-nth-mod nums -11) ; error
;
;; test q4
(define ones (lambda () (cons 1 ones)))
(stream-for-n-steps ones 5)
(stream-for-n-steps ones 15)
(stream-for-n-steps ones 0)

;; test q5
(define funny-test (stream-for-n-steps funny-number-stream 16))
funny-test

;; test q6
(stream-for-n-steps dan-then-dog 6)

;; test q7
(stream-for-n-steps (stream-add-zero dan-then-dog) 6)

;; test q8
(stream-for-n-steps (cycle-lists '(1 2 3) '("a" "b")) 6)

; a zero-argument function: call (one-visual-test) to open the graphics window, etc.
(define (one-visual-test)
  (place-repeatedly (open-window) 0.5 (cycle-lists nums files) 27))

;(one-visual-test)

; similar to previous but uses only two files and one position on the grid
(define (visual-zero-only)
  (place-repeatedly (open-window) 0.5 (stream-add-zero dan-then-dog) 27))
;(visual-zero-only)

;; test q9
(define v1 (vector 1 (cons 2 3) 3 4))
(vector-assoc 4 v1)
(vector-assoc 2 v1)

;; test q10
(define vlong (vector 1 (cons 2 3) (cons 3 5) (cons 4 8)))
(define cache5 (cached-assoc vlong 5)) 
(cache5 2)
(cache5 2)
(cache5 3)
(cache5 3)
