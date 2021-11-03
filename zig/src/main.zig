const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;

const Position = struct {
    row: usize,
    col: usize,
};

const Sudoku = struct {
    data: [9][9]u8 = undefined,

    fn init(line: []const u8) anyerror!Sudoku {
        var s = Sudoku{};
        for (line) |c, i| {
            const row = i / 9;
            const col = i % 9;
            s.data[row][col] = c - 48;
        }
        return s;
    }

    fn pp(self: *Sudoku) anyerror!void {
        for (self.data) |row| {
            for (row) |number| {
                print("{d} ", .{number});
            }
            print("\n", .{});
        }
        print("\n", .{});
    }

    fn write(self: *Sudoku, file: std.fs.File) anyerror!void {
        for (self.data) |row| {
            for (row) |number| {
                try file.writer().print("{d} ", .{number});
            }
            try file.writer().print("\n", .{});
        }
        try file.writer().print("\n", .{});
    }

    fn nextEmpty(self: *Sudoku) ?Position {
        for (self.data) |row, i| {
            for (row) |number, j| {
                if (number == 0) {
                    return Position{ .row = i, .col = j };
                }
            }
        }
        return null;
    }

    fn canPut(self: *Sudoku, p: *const Position, number: u8) bool {
        var i: usize = 0;
        while (i < 9) : (i += 1) {
            if (self.data[p.row][i] == number) {
                return false;
            }
            if (self.data[i][p.col] == number) {
                return false;
            }
        }
        // square test
        var a = p.row - (p.row % 3);
        var b = p.col - (p.col % 3);
        i = a;
        while (i < a + 3) {
            var j = b;
            while (j < b + 3) {
                if (self.data[i][j] == number) {
                    return false;
                }
                j += 1;
            }
            i += 1;
        }
        return true;
    }

    fn solve(self: *Sudoku) void {
        var p = self.nextEmpty() orelse return;
        var i: u8 = 1;
        while (i < 10) : (i += 1) {
            if (self.canPut(&p, i)) {
                self.data[p.row][p.col] = i;
                self.solve();
                if (self.nextEmpty() == null) {
                    // solution found
                    return;
                }
            }
        }
        // solution not found, backtrack
        self.data[p.row][p.col] = 0;
    }
};

const Gpa = std.heap.GeneralPurposeAllocator(.{});
pub fn main() anyerror!void {
    var args = std.process.args();
    _ = args.nextPosix(); // skip binary name
    const input = args.nextPosix() orelse {
        print("Usage: <bin> input\n", .{});
        return error.InvalidArgs;
    };
    const file = try std.fs.cwd().openFile(input, .{});
    defer file.close();
    const reader = std.io.bufferedReader(file.reader()).reader();
    var buf: [1024]u8 = undefined;
    var gpa = Gpa{};
    var galloc = &gpa.allocator;
    defer _ = gpa.deinit();
    var lines = std.ArrayList([]const u8).init(galloc);
    defer lines.deinit();
    while (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const new_str = try galloc.alloc(u8, line.len);
        std.mem.copy(u8, new_str, line);
        try lines.append(new_str);
    }
    defer for (lines.items) |line| {
        galloc.free(line);
    };
    const output_name = try std.fmt.allocPrint(galloc, "solved_{s}", .{std.fs.path.basename(input)});
    defer galloc.free(output_name);
    const output = try std.fs.cwd().createFile(output_name, .{});

    // const start = std.time.milliTimestamp();
    for (lines.items) |line| {
        var sudoku = try Sudoku.init(line);
        sudoku.solve();
        try sudoku.write(output);
    }
    // print("Elapsed time: {d} ms\n", .{std.time.milliTimestamp() - start});
}

test "Sudoku test" {
    var s = try Sudoku.init("008009320000080040900500007000040090000708000060020000600001008050030000072900100");
    try s.pp();

    // next empty
    const next = s.nextEmpty().?;
    try expect(next.row == 0);
    try expect(next.col == 0);

    // can put
    try expect(s.canPut(&Position{ .row = 0, .col = 0 }, 1));
    try expect(!s.canPut(&Position{ .row = 0, .col = 0 }, 8));
    try expect(!s.canPut(&Position{ .row = 0, .col = 0 }, 6));
    try expect(!s.canPut(&Position{ .row = 8, .col = 0 }, 5));

    s.solve();
    try s.pp();
    try expect(s.nextEmpty() == null);
}
