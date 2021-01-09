-- sudoku solver using backtrack
module Main where

import Control.DeepSeq(deepseq)
import Data.Char(ord)
import Data.List(intercalate, elemIndex, find)
import Data.Maybe(isNothing)
import Data.Time.Clock(diffUTCTime, getCurrentTime)
import System.Environment(getArgs)
import System.IO(hFlush, stdout)
import Text.Printf(printf)
import System.FilePath

boardSize = 9

groupN _ [] = []
groupN n xs = a : groupN n b where
                    (a,b) = splitAt n xs

fromStr = groupN boardSize . map toInt
        where toInt = abs . (48 -) . ord

toStr = unlines . map (intercalate " " . map show)

-- return the next row, column where value is zero
nextEmpty sudoku = case (elemIndex 0 (concat sudoku)) of
        Just n  -> [n `div` boardSize, n `mod` boardSize]
        Nothing -> []

-- return true if val can be put at row and col of sudoku
canPut sudoku row col val =
        and [val `notElem` (sudoku !! row), -- test row
                 val `notElem` [r !! col | r <- sudoku], -- test column
        -- test square
             val `notElem` [sudoku!!i!!j | i <- [sqX .. sqX+2], j <- [sqY .. sqY+2]]]
        where
                sqX = row - (row `mod` 3)
                sqY = col - (col `mod` 3)

updateList xs pos val = x ++ val : ys
        where (x,_:ys) = splitAt pos xs

updateSudoku sudoku row col val = updateList sudoku row (updateList (sudoku!!row) col val)

-- solve a sudoku, return the solved sudoku if found solution or the same otherwise
solve sudoku
        | spot == [] = sudoku -- sudoku is solved
        | otherwise =
                let (row:col:_) = spot
                in
                        case find (\s -> nextEmpty s == []) (map (\val->(if canPut sudoku row col val
                                then solve (updateSudoku sudoku row col val)
                                else sudoku)) [1..9]) of
                                        Just s -> s
                                        Nothing -> sudoku
        where
                spot = nextEmpty sudoku

-- progress bar
loadBar :: Int -> Int -> Int -> Int -> IO()
loadBar step totalSteps resolution width =
        if (and [(div totalSteps resolution /= 0), (mod step (div totalSteps resolution) /= 0)])
                then do
                        let ratio = (fromIntegral step::Float) / (fromIntegral totalSteps::Float)
                        let count = floor (ratio * (fromIntegral width::Float))
                        let perc = floor (ratio * 100)
                        printf "%3d%% [" (perc::Int)
                        mapM (\_ -> printf "=") [0..count-1]
                        mapM (\_ -> printf " ") [count..width-1]
                        printf "]\r"
                        hFlush stdout
                        return()
                else
                        return()

process :: Int -> Int -> String -> IO String
process step totalSteps sudoku = do
        let result = (toStr . solve . fromStr) sudoku
        result `deepseq` loadBar step totalSteps 20 50 -- deepseq forces evaluation of result
        return result

main = do
        -- read entire file into memory
        (input:_) <- getArgs
        contents <- readFile input
        let sudokus = lines contents
        let total = length sudokus

        -- solve all sudokus
        start <- getCurrentTime
        let result = intercalate "\n" $ map (toStr . solve .fromStr) $ sudokus
        solutions <- mapM (\(step,sudoku) -> process step total sudoku) (zip [1..] sudokus)
        let result = intercalate "\n" solutions
        end <- getCurrentTime

        -- present results
        putStrLn $ " -- Elapsed time: " ++ (show (diffUTCTime end start))
        writeFile ("solved_" ++ (takeFileName input)) result
