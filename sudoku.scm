(import (rnrs base))
(use-modules (srfi srfi-9))
(use-modules (srfi srfi-9 gnu))
(use-modules (srfi srfi-1))

;; represents a sudoku board
(define-immutable-record-type <board>
  (make-board grid)
  board?
  (grid board-grid set-board-grid))

;; customize printer for the board record type
(set-record-type-printer!
 <board>
 (lambda (record out)
   (do ((i 0 (1+ i)))
       ((= i 9))
     (begin
       (do ((j 0 (1+ j)))
	   ((= j 9))
	 (format out "~a " (board-get record i j)))
       (newline out)))))

;; returns the number at row i and column j
(define (board-get board i j)
  (array-ref (board-grid board) i j))

;; returns a new board from a one line sudoku string
(define (make-board-from-string string)
  (let ((grid (make-array 0 9 9))
	(i 0)
	(j 0))
    (string-for-each
     (lambda (x)
       (array-set! grid (- (char->integer x) 48) i j)
       (set! j (+ j 1))
       (when (= j 9)
	 (begin (set! j 0) (set! i (+ i 1))))) string)
    (make-board grid)))

;; example
(define b (make-board-from-string "200000060000075030048090100000300000300010009000008000001020570080730000090000004"))
(assert (board? b))

;; returns a board position where there is a zero
(define (board-next-empty-place board)
  (let ((zeroes
	 (map (lambda (x) (list (car x) (cadr x)))
	      (filter (lambda (x) (zero? (caddr x)))
		      (reduce-right append '()
				    (map (lambda (x) (map (lambda (y) (list x y (board-get board x y))) (iota 9))) (iota 9)))))))
    (if (null? zeroes)
	zeroes
	(car zeroes))))

(assert (equal? '()
		(board-next-empty-place (make-board (make-array 1 9 9)))))
(assert (equal? (list 0 1) (board-next-empty-place b)))

(define (cartesian-product . lists)
  (fold-right (lambda (xs ys)
                (append-map (lambda (x)
                              (map (lambda (y)
                                     (cons x y))
                                   ys))
                            xs))
              '(())
              lists))

(define (can-put-square? board row col number)
  (let* ((min-x (- row (mod row 3)))
         (min-y (- col (mod col 3)))
         (max-x (+ min-x 3))
         (max-y (+ min-y 3)))
    (not
     (member
      number
      (map
       (lambda (position)
         (board-get board (car position) (cadr position)))
       (cartesian-product (iota 3 min-x) (iota 3 min-y)))))))

(assert (not (can-put-square? b 0 1 8)))
(assert (can-put-square? b 0 1 7))
(assert (can-put-square? b 0 1 6))
(assert (can-put-square? b 0 1 5))
(assert (not (can-put-square? b 0 1 4)))
(assert (can-put-square? b 0 1 3))
(assert (not (can-put-square? b 0 1 2)))
(assert (can-put-square? b 0 1 1))

;; returns #t if the number can be put in the board
(define (can-put? board row col number)
  (define (not-in-row? board row val)
    (let ((xs (array-slice (board-grid board) row)))
      (not (member val (array->list xs)))))
  (define (not-in-col? board col val)
    (call/cc
     (lambda (return)
       (do ((i 0 (1+ i)))
	   ((= i 9))
	 (when (= val (board-get board i col)) (return #f)))
       #t)))
  (and
   (not-in-row? board row number)
   (not-in-col? board col number)
   (can-put-square? board row col number)))

;; set the number in the row and column
(define (board-set! board row col number)
  (array-set! (board-grid board) number row col))

;; returns a new board with the number placed in row and column
(define (board-set board row col number)
  (define dst (make-array 0 9 9))
  (array-copy! (board-grid board) dst)
  (array-set! dst number row col)
  (make-board dst))

;; return a list of boards where the next empty place is filled with a possible value
(define (try board)
  (let ((next-empty (board-next-empty-place board)))
    (if (null? next-empty)
        '()
        (filter-map
         (lambda (number)
           (if (can-put? board (car next-empty) (cadr next-empty) number)
               (board-set board (car next-empty) (cadr next-empty) number)
               #f))
         (iota 9 1)))))

;; solve the sudoku
(define (solve board)
  (let ((next-empty (board-next-empty-place board)))
    (if (null? next-empty)
        board
        (call/cc
         (lambda (return)
           (let ((x (car next-empty))
                 (y (cadr next-empty)))
             (do ((number 1 (1+ number)))
                 ((= 10 number))
               (when (can-put? board x y number)
                 (board-set board x y number)
                 (solve board)
                 (when (null? (board-next-empty-place board))
                   (return board))))
             (when (not (null? (board-next-empty-place board)))
               (format #t "Backtracking x = ~a, y = ~a ~%" x y)
               (board-set board x y 0))))))))
