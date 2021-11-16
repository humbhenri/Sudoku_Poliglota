# solve a sudoku using backtrack
use strict;
use autodie;
use warnings;
use Scalar::Util qw( looks_like_number );
use Time::HiRes qw( time );
use File::Basename;
use constant ROW_SIZE => 9;

sub next_empty {
    my $sudoku = shift;
    for my $row (0 .. ROW_SIZE-1) {
        for my $col (0 .. ROW_SIZE-1) {
            if ($$sudoku[$row][$col] == 0) { return ($row, $col); }
        }
    }
    return ();
}

sub can_put {
    my ($sudoku, $x, $y, $val) = @_;
    for my $i (0 .. ROW_SIZE - 1) {
        if ($$sudoku[$x][$i] == $val) { return 0; }
        if ($$sudoku[$i][$y] == $val) { return 0; }
    }
    my $sq_x = $x - ($x % 3);
    my $sq_y = $y - ($y % 3);
    for my $row ($sq_x .. $sq_x + 2) {
        for my $col ($sq_y .. $sq_y + 2) {
            if ($$sudoku[$row][$col] == $val) {
                return 0;
            }
        }
    }
    return 1;

}

sub solve {
    my $sudoku = shift;
    my @spot = next_empty $sudoku;
    if (@spot) {
        my ($x, $y) = @spot;
        for my $val (1 .. 9) {
            if (can_put $sudoku, $x, $y, $val) {
                $$sudoku[$x][$y] = $val;
                my $new_sudoku = solve ($sudoku);
                my @new_spot = next_empty $new_sudoku;
                if (@new_spot == 0) {return $new_sudoku; } # solution found
            }
        }
        $$sudoku[$x][$y] = 0; # backtrack
    }
    return $sudoku;
}

sub from_str {
    my @sudoku = ();
    my $str = shift;
    my @numbers = grep { looks_like_number($_) } split(//, $str);
    for my $i (map {ROW_SIZE * $_} 0..ROW_SIZE-1) {
        push @sudoku, [@numbers[$i .. ($i+ROW_SIZE-1)]];
    }
    return @sudoku;
}

sub to_str {
    my $sudoku = shift;
    my $result = "";
    foreach my $row (@$sudoku) {
        $result .= " @$row \n";
    }

    return $result;
}

sub load_bar {
    my ($step, $totalSteps, $resolution, $width) = @_;
    if (int($totalSteps/$resolution) != 0 and 
        $step % int($totalSteps/$resolution) == 0) {
        my $ratio = $step/$totalSteps;
        my $count = int($ratio * $width);
        printf("%d%% [",int($ratio * 100));
        for (0 .. $count) { printf("="); }
        for ($count+1 .. $width) { printf(" "); }
        printf("]\r");
        $|++; #flush
    }
    return;
}

# read sudokus into memory
my $input = $ARGV[0];
open my $in, "<", $input;
my $data;
read $in, $data, -s $input;
close $in;

my $result = "";
my $start_time = time();

# solve all sudokus
my @rows = split '\n', $data;
my $total = @rows;
for my $step (0 .. $#rows) {
    my @sudoku = from_str($rows[$step]);
    $result .= to_str( solve (\@sudoku)) . "\n";
    load_bar($step, $total, 20, 50);
}
my $diff = time() - $start_time;

# write solutions to file
open my $fh, ">", "solved_" . basename($input);
print $fh $result;
close $fh;

print " -- Elapsed time: $diff s.\n";

1;
