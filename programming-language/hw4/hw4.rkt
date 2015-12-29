#lang racket

(provide (all-defined-out)) ;; so we can put tests in a second file

;; put your code below
;; q1
(define (sequence low high stride)
  (if (>= high low)
    (cons low (sequence (+ low stride) high stride))
    null))
  
;; q2
(define (string-append-map xs suffix)
  (map (lambda (x) (string-append x suffix)) xs))

;; q3
(define (list-nth-mod xs n)
  (let* ([len (length xs)]
	 [index (remainder n len)])
    (cond [(< n 0) (error "list-nth-mod: negative number")]
          [(null? xs) (error "list-nth-mod: empty list")]
	  [else (car (list-tail xs index))])))

;; q4
(define (stream-for-n-steps stream n)
  (let ([next (stream)])
    (if (= n 0)
      null
      (cons (car next) (stream-for-n-steps (cdr next) (- n 1))))))
    
;; q5
;; copied from lecture code
(define (stream-maker fn arg)
  (letrec ([f (lambda (x) 
                (cons x (lambda () (f (fn x arg)))))])
    (lambda () (f arg))))

(define funny-number-stream 
  (stream-maker 
    (lambda (a b) 
      (let ([ab (+ a b)])
	(if (= 0 (remainder ab 5))
	  (- 0 ab)
	  (+ (abs a) b)))) 1)) 
       
;; q6
(define dan-then-dog 
  (lambda () (cons "dan.jpg" (lambda () (cons "dog.jpg" dan-then-dog)))))

;; q7
(define (stream-add-zero stream)
  (let ([next (stream)])
    (lambda () (cons (cons 0 (car next)) (stream-add-zero (cdr next)))))) 

;; q8
;; assume both lists xs ys are not empty
(define (cycle-lists xs ys)
  (define (count-lists n)
    (lambda () (cons (cons (list-nth-mod xs n) 
			   (list-nth-mod ys n)) (count-lists (+ n 1)))))
  (count-lists 0)) 

;; q9
(define (vector-assoc v vec)
  (let ([len (vector-length vec)])
    (define (loop n)
      (if (= n len) 
	#f
	(let ([nth-vec (vector-ref vec n)])
	  (cond [(not (pair? nth-vec)) (loop (+ 1 n))] 
		[(equal? v (car nth-vec)) nth-vec]
		[#t (loop (+ 1 n))]))))
    (loop 0)))

;; q10
(define (cached-assoc xs n)
  (letrec ([memo (build-vector n add1)] ;vector of n int
	   [pos 0]
	   [len (vector-length xs)]
	   [f (lambda (v)
		(let ([cans (vector-assoc v memo)])
		  (if cans ;cans is cached
		    (begin
		      (print "hit!\n")
		      cans)
		    (let ([ans (vector-assoc v xs)])
		      (if ans 
			(begin 
			  (vector-set! memo pos ans)
			  (set! pos (remainder (+ 1 pos) len)))
			#f)))))])
	   f))


(define-syntax my-if 
    (syntax-rules (then else)
		      [(my-if e1 then e2 else e3)
		            (if e1 e2 e3)]))
(my-if #t then 5 else 3)

(define-syntax my-delay
    (syntax-rules ()
		      [(my-delay e)
		            (mcons #f (lambda () e))]))

(define-syntax while-less
  (syntax-rules (do)
	       [(while-less e1 do e2)
		(let ([de1 (my-delay e1)]
		      [de2 (my-delay e2)])
		  (define (loop e2)
		    (if (> de1 (my-delay e2))
		      #t
		      (loop (my-delay e2))))
		  (loop e2))]))
			 
		   
(define a 2)
(while-less 7 do (begin (set! a (+ a 1)) (print "x") a))
;;(while-less 7 do (begin (set! a (+ a 1)) (print "x") a))
