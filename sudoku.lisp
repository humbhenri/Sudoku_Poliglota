;;; Solve sudokus using a backtrack recursion approach

(defconstant +board-size+ 81)
(defconstant +row-size+ 9)

;;; read file and resturn contents
(defun slurp-file (stream)
  (let ((seq (make-array (file-length stream) :element-type 'character :fill-pointer t)))
    (setf (fill-pointer seq) (read-sequence seq stream))
    seq))


;;; given a 81 length line returns a 9x9 array
(defun from-str (text)
  (let ((board (make-array (list +row-size+ +row-size+) :element-type 'integer)))
    (loop
       for i being the elements of text
       for x = 0 then (if (= y (- +row-size+ 1)) (+ x 1) x)
       for y = 0 then (mod (+ y 1) +row-size+)
       do (setf (aref board x y) (digit-char-p i)))
    board))


;;; given a 9x9 array returns a string representation
(defun to-str (board)
  (let ((dims (array-dimensions board))
        (text ""))
    (dotimes (i (first dims))
      (dotimes (j (second dims))
        (setf text (concatenate 'string text (format nil "~a " (aref board i j)))))
      (setf text (concatenate 'string text (format nil "~%"))))
    (concatenate 'string text (format nil "~%"))))


;;; given a 9x9 array sudoku returns the first found soultion or the same sudoku if not solution found
(defun solve (sudoku)
  
  ;; helper functions 
  (flet 
        ; given a sudoku returns the first row and column with a empty space 
        ((next-empty (a-sudoku)
           (loop for i from 0 below +row-size+ do
                (loop for j from 0 below +row-size+
                   when (= (aref a-sudoku i j) 0) do (return-from next-empty (list i j)))))

        ; given a sudoku returns true only if val can be put at row x and column y 
         (can-put (a-sudoku x y val) (and (loop for i from 0 to (- +row-size+ 1)
                                             never (= (aref a-sudoku i y) val) ; test rows
                                             never (= (aref a-sudoku x i) val)) ; test columns
                                          (not (let ((sq-x (- x (mod x 3))) ;test subsquares
                                                     (sq-y (- y (mod y 3))))
                                                 (loop named outer for i from sq-x to (+ sq-x 2) do
                                                      (loop for j from sq-y to (+ sq-y 2) do
                                                           (when (= (aref a-sudoku i j) val)
                                                             (return-from outer t)))))))))

    (let ((spot (next-empty sudoku)))
      (when spot
        (destructuring-bind (x y) spot
          (loop for val from 1 to 9
             when (can-put sudoku x y val) do
               (setf (aref sudoku x y) val)
               (solve sudoku)
               (unless (next-empty sudoku)
                 (return-from solve)))
          (setf (aref sudoku x y) 0)))))) ;solution not found, backtrack

;;;
;;; read entire file into memory
;;;
(defparameter inputname (or (second *posix-argv*) "input_huge.txt"))
(defparameter data "")
(with-open-file (stream inputname)
  (setf data (remove-if-not #'digit-char-p (slurp-file stream))))

;;;
;;; resolve all sudokus
;;;
(defparameter result "")

(let ((before (get-internal-run-time)))
  (loop initially (setf result "")
     repeat (/ (length data) +board-size+)
     for start = 0 then (+ start +board-size+)
     for row = (subseq data start (+ start +board-size+))
     for sudoku = (from-str row)
     do (solve sudoku)
       (setf result (concatenate 'string result (to-str sudoku))))
  (format t "--Elapsed time: ~a ms ~%" (* 1000 (/ (- (get-internal-run-time) before) internal-time-units-per-second))))

;;; write results to file
(let* ((input (file-namestring (pathname inputname)))
       (filename (concatenate 'string "solved_" input)))
  (with-open-file (stream filename :direction :output :if-exists :supersede)
    (format stream "~a~%" result)))
