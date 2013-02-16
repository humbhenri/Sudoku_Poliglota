//
//  main.m
//  sudoku
//  Solve sudokus using backtrack
//  Created by Humberto Pinheiro on 26/01/13.
//  Copyright (c) 2013 Humberto Pinheiro. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ROW_SIZE 9

// progress bar
static inline void load_bar(int step, int total_steps, int resolution, int width) {
    if (total_steps/resolution == 0) return; // avoid a division by zero below
    if (step % (total_steps/resolution) != 0) return;
    float ratio = step/(float)total_steps;
    int count = ratio * width;
    printf("%3d%% [", (int)(ratio*100));
    
    // Show the load bar.
    for (int x=0; x<count; x++)
        printf("=");
    for (int x=count; x<width; ++x)
        printf(" ");
    printf("]\r");
    fflush(stdout);
}


// return a sudoku from a 81 character line
NSArray* from_str(NSString* line) {
    NSMutableArray* sudoku = [NSMutableArray arrayWithCapacity:ROW_SIZE];
    for (int i=0; i<ROW_SIZE; i++) {
        [sudoku insertObject:[NSMutableArray arrayWithObjects:0, 0, 0, 0, 0, 0, 0, 0, 0, nil] atIndex:i];
    }
    NSUInteger len = [line length];
    NSUInteger row =0, col = 0;
    unichar buffer[len + 1];
    [line getCharacters:buffer range:NSMakeRange(0, len)];
    for (int i = 0; i < len; i++) {
        if (isdigit(buffer[i])) {
            [[sudoku objectAtIndex:row] setObject:[NSNumber numberWithInt:(buffer[i]-48)] atIndex:col++];
            row = col == ROW_SIZE ? row + 1 : row;
            col = col % ROW_SIZE;
        }
    }
    return sudoku;
}


// Return a string representing the sudoku
NSString* to_str(NSArray* sudoku) {
    NSMutableString* result = [NSMutableString new];
    [result appendString:@"\n"];
    for (int i=0; i<[sudoku count]; i++) {
        for (int j=0; j<[[sudoku objectAtIndex:i] count]; j++) {
            NSNumber* n = [[sudoku objectAtIndex:i] objectAtIndex:j];
            [result appendFormat:@"%@ ", n];
        }
        [result appendString:@"\n"];
    }
    [result appendString:@"\n"];
    return result;
}


// return the next spot to put a value or nil if the sudoku is full
NSArray* next_empty(NSArray* sudoku) {
    NSMutableArray* spot = [NSMutableArray new];
    NSNumber* zero = [NSNumber numberWithInt:0];
    for (int i=0; i<[sudoku count]; i++) {
        for (int j=0; j<[[sudoku objectAtIndex:i] count]; j++) {
            if ([[sudoku objectAtIndex:i] objectAtIndex:j] == zero) {
                [spot insertObject:[NSNumber numberWithInt:i] atIndex:0];
                [spot insertObject:[NSNumber numberWithInt:j] atIndex:1];
                return spot;
            }
        }
    }
    return nil;
}


// return true if val in [row col] doesnt violate the rules
bool can_put(NSArray* sudoku, int row, int col, NSNumber* val) {
    for (int i=0; i<ROW_SIZE; i++) {
        if ([[sudoku objectAtIndex:i] objectAtIndex:col] == val) return false; // test in column
        if ([[sudoku objectAtIndex:row] objectAtIndex:i] == val) return false; // test in row
    }
    // test in square
    int sq_x = row - (row%3);
    int sq_y = col - (col%3);
    for (int i=sq_x; i<sq_x + 3; i++) {
        for (int j=sq_y; j<sq_y+3; j++) {
            if ([[sudoku objectAtIndex:i] objectAtIndex:j] == val) return false;
        }
    }
    return true;
}


// recursive algorithm to solving sudokus
NSArray* solve(NSArray* sudoku) {
    NSArray* spot = next_empty(sudoku);
    if (spot != nil) {
        NSNumber* row = [spot objectAtIndex:0];
        NSNumber* col = [spot objectAtIndex:1];
        for (int i=1; i<10; i++) {
            NSNumber* val = [NSNumber numberWithInt:i];
            if (can_put(sudoku, [row intValue], [col intValue], val)) {
                [[sudoku objectAtIndex:[row intValue]] setObject:val atIndex:[col intValue]];
                NSArray* new_sudoku = solve(sudoku);
                if (! next_empty(new_sudoku)) {
                    // solution found
                    return new_sudoku;
                }
            }
        }
        // solution not found backtrack
        [[sudoku objectAtIndex:[row intValue]] setObject:[NSNumber numberWithInt:0] atIndex:[col intValue]];
    }
    return sudoku;
}


int main(int argc, const char * argv[])
{

    @autoreleasepool {
        
        NSString* input = [NSString stringWithCString:argv[1] encoding:NSASCIIStringEncoding];

        
        // load all sudokus into memory
        NSString* data = [NSString stringWithContentsOfFile:input encoding:NSASCIIStringEncoding error:nil];
        data = [data stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n\r\t"]];
        
        if (data == nil) {
            NSLog(@"Cannot read data from %@\n", input);
        }
        
        NSMutableString* results = [NSMutableString new];
        
        // solve all sudokus
        NSArray* sudokus = [data componentsSeparatedByString:@"\n"];
        int sudokus_solved = 0;
        int total_sudokus = (int)[sudokus count];
        NSDate* start = [NSDate date];
        for (NSString* line in sudokus) {
            NSArray* sudoku = solve(from_str(line));
            [results appendString:to_str(sudoku)];
            load_bar(++sudokus_solved, total_sudokus, 100, 100);
        }
        NSTimeInterval elapsed = [start timeIntervalSinceNow];
        
        // write solutions to file
        NSString* output = [NSString stringWithFormat:@"solved_%@", [input lastPathComponent]];
        [results writeToFile:output atomically:NO encoding:NSASCIIStringEncoding error:nil];

        // present results
        NSLog(@"-- Elapsed: %f s\n", -elapsed);
    }
    return 0;
}

