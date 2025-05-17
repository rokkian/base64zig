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

    // stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Run `zig build test` to run the tests.\n", .{});
    

    try bw.flush(); // Don't forget to flush!

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

