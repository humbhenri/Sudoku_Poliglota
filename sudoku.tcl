#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

set board_size 9

proc from_str {str} {
    global board_size
    regsub {[^0-9]} $str "" sudoku
    set sudoku [split $sudoku {}]
    for {set i 0} {$i < [llength $sudoku]} {incr i} {        
        lset sudoku $i [expr [lindex $sudoku $i]]
    }
    return $sudoku
}

proc to_str {board} {
    global board_size
    set output ""
    for {set i 0} {$i < [llength $board]} {set i [expr {$i + $board_size}]} {
        append output [join [lrange $board $i [expr {$i + $board_size - 1}]]] "\n"
    }
    return $output
}

proc next_empty {sudoku} {
    global board_size
    for {set i 0} {$i < [llength $sudoku]} {incr i} {
        set n [lindex $sudoku $i]        
        if {$n == 0} {            
            set row [expr {$i / $board_size}]
            set col [expr {$i % $board_size}]
            return [list $row $col]
        }
    }
    return {}
}

proc can_put {sudoku row col val} {
    global board_size    
    for {set i 0} {$i < $board_size} {incr i} {
        set c [lindex $sudoku [expr {$col + $i * $board_size}]]
        set r [lindex $sudoku [expr {$row * $board_size + $i}]]
        if {$r == $val} { ;# test rows
            return false
        }
        if {$c == $val} { ;# test columns
            return false
        }
    }
    # test square
    set sub_row [expr {$row-($row%3)}]
    set sub_col [expr {$col-($col%3)}]
    for {set i $sub_row} {$i < $sub_row + 3} {incr i} {
        for {set j $sub_col} {$j < $sub_col + 3} {incr j} {
            set index [expr {$i*$board_size + $j}]
            if {[lindex $sudoku $index] == $val} {
                return false
            }
        }
    }
    return true
}

proc solve {sudoku} {
    global board_size
    set spot [next_empty $sudoku]
    if {[llength $spot] == 0} {
        return $sudoku
    }
    set x [lindex $spot 0]
    set y [lindex $spot 1]
    set index [expr {$x*$board_size + $y}]
    for {set val 1} {$val < 10} {incr val} {
        if {[can_put $sudoku $x $y $val]} {            
            lset sudoku $index $val
            set sudoku_ [solve $sudoku]
            if {[llength [next_empty $sudoku_]] == 0} {
                # solution found
                return $sudoku_
            }
        }
    }
    # solution not found, backtrack
    lset sudoku $index 0
    return $sudoku
}

proc solve_sudokus {data} {
    global result
    foreach line [split $data "\n"] {
        set sudoku [from_str $line]
        append result [to_str [solve $sudoku]] "\n"
    }    
}

# load input file into memory
set input [open [lindex $argv 0] r]
set data [read $input]
close $input

# solve all sudokus
set result ""
puts [time {solve_sudokus $data}]

# write solutions to file
set filename "solved_[file tail [lindex $argv 0]]"
set output [open $filename w]
puts -nonewline $output $result
close $output


