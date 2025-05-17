//! By convention, main.zig is where your main function lives in the case that
//! you are building an executable. If you are making a library, the convention
//! is to delete this file and start with root.zig instead.

const std = @import("std");
const zeit = @import("zeit");

/// This imports the separate module containing `root.zig`. Take a look in `build.zig` for details.
const lib = @import("base64zig_lib");


pub fn main() !void {
    // Prints to stderr (it's a shortcut based on `std.io.getStdErr()`)
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    std.debug.print("Starting: Unix time (seconds): {d}\n", .{std.time.timestamp()});

    const time = get_current_time_date();
    std.debug.print("The current time is: {!s}\n", .{time});

    // -- Base64 code ---

    const base64 = Base64.init();
    const index_var = 28;
    std.debug.print("Character at index {d}: {c}\n", .{index_var, base64._char_at(index_var)});




    // -- Base64 end code ---

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});
    

    try bw.flush(); // Don't forget to flush!

}

const Base64 = struct {
    _table: *const [64]u8,

    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const numbers_symb = "0123456789+/";
        return Base64{
            ._table = upper ++ lower ++ numbers_symb,
        };
    }

    pub fn _char_at(self: Base64, index: usize) u8 {
        return self._table[index];
    }
};

fn _calc_encode_lenght(input: []const u8) !usize {
    // Returns the expected amount of bytes of the encoded document
    if (input.len <= 3) {
        return 4;
    }
    const n_groups: usize = try std.math.divCeil(usize, input.len, 3);

    return n_groups * 4;
}

fn _calc_decode_length(input: []const u8) !usize {
    if (input.len < 4) {
        return 3;
    }

    const n_groups: usize = try std.math.divFloor(
        usize, input.len, 4
    );
    var multiple_groups: usize = n_groups * 3;
    var i: usize = input.len - 1;
    while (i > 0) : (i -= 1) {
        if (input[i] == '=') {
            multiple_groups -= 1;
        } else {
            break;
        }
    }

    return multiple_groups;
}

fn get_current_time_date() ![]const u8{
    const allocator = std.heap.page_allocator;
    var env = try std.process.getEnvMap(allocator);
    defer env.deinit();

    // Get an instant in time. The default gets "now" in UTC
    const now = try zeit.instant(.{});

    // Load our local timezone. This needs an allocator. Optionally pass in a
    // *const std.process.EnvMap to support TZ and TZDIR environment variables
    const local = try zeit.local(allocator, &env);

    // Convert our instant to a new timezone
    const now_local = now.in(&local);

    // Generate date/time info for this instant
    const dt = now_local.time();

    // Prepare a buffer for the formatted string
    var formatted = std.ArrayList(u8).init(allocator);
    defer formatted.deinit();

    // Format using strftime-style format string
    try dt.strftime(formatted.writer(), "%Y-%m-%d %H:%M:%S %Z");

    // Print the formatted string
    std.debug.print("{!s}\n", .{formatted.items});

    // Print it out
    return std.fmt.allocPrint(allocator, "Hello, {!s}!\n", .{formatted.items});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // Try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "use other module" {
    try std.testing.expectEqual(@as(i32, 150), lib.add(100, 50));
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}

test "base64 encoding lenght 2" {
    try std.testing.expectEqual(4, _calc_encode_lenght("ab"));
}

test "base64 encoding lenght 6" {
    try std.testing.expectEqual(8, _calc_encode_lenght("abcabc"));
}

