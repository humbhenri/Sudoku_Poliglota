(defproject clojureapp "0.1.0-SNAPSHOT"
  :description "sudoku solving app"
  :url "http://example.com/"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.10.3"]]
  :main ^:skip-aot clojureapp.core
  :target-path "target/%s"
  :profiles {:uberjar {:aot :all}})
