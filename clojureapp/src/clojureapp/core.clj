(ns clojureapp.core
  (:gen-class))

(use '[clojure.string :only [join]])
(import '[java.io File])

(defn from-str [board-repr]
  (->>
   (filter #(Character/isDigit %) board-repr)
   (map (comp - (partial - 48) int))
   (partition 9)
   (map (partial into []))
   (into [])))

(defn to-str [board]
  (join "\n" (for [row board]
               (join " " row))))

(defn next-empty [board]
  (first (for [x (range 9) y (range 9) :when (= 0 (get-in board [x y]))]
           [x y])))

(defn can-put? [board [row col] i]
  (and (nil? (some #{i} (get board row)))                                 ; test in row
       (nil? (some #{i} (for [x (range 9)] (get-in board [x col]))))      ; test in column
       (nil? (some #{i} (for [x (take 3 (iterate inc (- row (mod row 3)))); test in square
                              y (take 3 (iterate inc (- col (mod col 3))))]
                          (get-in board [x y]))))))

(defn solve [board]
  (if-let [[x y] (next-empty board)]
    (or (first (filter (comp nil? next-empty)
                       (for [i (range 1 10)
                             :when (can-put? board [x y] i)
                             :let [board* (-> (assoc-in board [x y] i) (solve))]] board*)))
        board) ; impossible from here, backtrack
    board))


;;; progress bar
(defn load-bar [step total-steps resolution width]
  (if (= 0 (int (/ total-steps resolution)))
    (load-bar (* 10 step) (* 10 total-steps) resolution width)
    (when-not (= 0 (mod step (int (/ total-steps resolution))))
      (let [ratio (/ step total-steps)
            count (int (* ratio width))]
        (printf "%3d%% [" (int (* ratio 100)))
        (dotimes [_ count]
          (printf "="))
        (dotimes [_ (- width count)]
          (printf " "))
        (printf "]\r")
        (flush)))))


(defn solve-batch [sudokus]
  (let [total (count sudokus)
        solve-sudoku #(-> (nth sudokus %)
                          (from-str)
                          (solve)
                          (to-str))]
    (loop [step 0
           result (str (solve-sudoku step) "\n\n")]
      (load-bar step total 20 50)
      (if (= step (dec total))
        result
        (recur (inc step)
               (str result (solve-sudoku (inc step)) "\n\n"))))))


(defn -main [& args]
  (when-let [[input] args]
    (spit (str "solved_" (.getName (File. input)))
          (-> (slurp input)
              (.split "\n")
              (solve-batch)
              (time)))))

(apply -main *command-line-args*)
