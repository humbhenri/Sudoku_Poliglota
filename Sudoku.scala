import java.io.File
import java.util.Scanner
import java.io.BufferedWriter
import java.io.FileWriter

// Build a sudoku from a 81 char line
class Sudoku(text: String) {
	val rowSize = 9
  
	val board = Array.ofDim[Integer](rowSize, rowSize)
	var i = 0
	var j = 0
	for (char <- text) {
		board(i)(j) = char.toInt - 48
		if (j == rowSize - 1) {
			i += 1 % rowSize
			j = 0
		} else {
			j += 1 % rowSize
		}
	}
	
	override def toString:String =
	{
		val sb = new StringBuilder()
		val lineSep = System.getProperty("line.separator")
		for (row:Array[Integer] <- this.board) yield {
		  sb.append((row map (i => i.toString)).mkString(" ")).append(lineSep)
		}
		sb.toString
	}
	
}

object SudokuSolver {
	
	def solve(sudoku:Sudoku):Sudoku =
	{
		val spot = nextEmpty(sudoku)
		spot match {
		  case None => sudoku
		  case Some((i,j)) =>
		    for (value <- 1 to 9) {
		    	if (canPut(sudoku, (i,j), value)) {
		    		sudoku.board(i)(j) = value
		    		val sudoku2 = solve(sudoku)
		    		if (!nextEmpty(sudoku2).isDefined) {
		    			return sudoku2 // solution found
		    		}
		    	}
		    }
		    // backtrack, solution not found
		    sudoku.board(i)(j) = 0
		    return sudoku
		}
	}
	
	def nextEmpty(sudoku:Sudoku):Option[Tuple2[Integer,Integer]] =
	{
		for (i <- 0 to sudoku.rowSize-1) {
			for (j <- 0 to sudoku.rowSize-1) {
				if (sudoku.board(i)(j) == 0) return Some((i,j)) 
			}
		}
		None
	}
	
	def canPut(sudoku:Sudoku, spot:Tuple2[Integer,Integer], value:Integer):Boolean =
	{
		for (i <- 0 to sudoku.rowSize-1) {
			// test row
			if (sudoku.board(i)(spot._2) == value) return false
			
			// test column
			if (sudoku.board(spot._1)(i) == value) return false
		}
		
		// test square
		val a = spot._1 - (spot._1%3)
		val b = spot._2 - (spot._2%3)
		for (i <- a to a+2) {
			for (j <- b to b+2) {
				if (sudoku.board(i)(j) == value) return false
			}
		}
		
		true
	}
}

class ProgressBar(var totalSteps:Integer, var step:Integer, var resolution:Integer, var width:Integer) {
	def advance 
	{
		step += 1
        if (totalSteps/resolution == 0) return
        if (step % (totalSteps/resolution) != 0) return
        var ratio:Float = step/totalSteps.toFloat
        val count:Int = (ratio * width).toInt
        print("%3d%% [".format((ratio * 100).toInt))
		(0 to count-1) foreach {_ => print("=")}
		(count to width-1) foreach {_ => print(" ")}
        print( "]\r ")
        System.out.flush()
	}
}

object Sudoku {

	def main(args: Array[String]) {
	  
		val file = new File(args(0))
		
		// read entire input into memory
		val input = new Scanner(file, "UTF-8").useDelimiter("\\A").next()
		
		val output = new StringBuilder()
		
		val before = System.nanoTime
		
		val lines = input.split("\\r?\\n")
		
		val progressBar = new ProgressBar(0, lines.length, 100, 100)

		val lineSep = System.getProperty("line.separator")
		for (line <- lines) {
			val sudoku = new Sudoku(line)
			output.append(SudokuSolver.solve(sudoku)).append(lineSep)
			progressBar.advance
		}
		
		// elapsed time
		println("\nElapsed time: " + ((System.nanoTime - before)/1e6) + " ms")
		
		// write solutions to file
		val writer = new BufferedWriter(new FileWriter("solved_" + file.getName()))
		writer.write(output.toString)
		writer.close
	}
}