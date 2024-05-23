const std = @import("std");
const debug = std.debug;
const io = std.io;
const Allocator = std.mem.Allocator;

const clap = @import("clap");

const frankenfest_filename = "frankenfest.json";

const description = (
    \\Frankenfest: A small cli utility to help manage multi-language monorepos
    \\Version: 0.0.1
    \\
    \\
);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const stdout_file = std.io.getStdOut().writer();
    var stdout_buffer = std.io.bufferedWriter(stdout_file);
    const stdout = stdout_buffer.writer();

    try stdout.print("Running Frankenrepo...\n", .{});

    const params = comptime clap.parseParamsComptime(
        \\-h, --help       Display this help and exit
        \\-C, --dir <str>  Directory to look for a frankenfest.json [Default: .]
        \\<str>
        \\
    );

    // init diagnostics
    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
        .allocator = allocator,
    }) catch |err| {
        diag.report(io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();

    // TODO: Parse args into a struct
    if (res.args.help != 0) {
        const writer = io.getStdErr().writer();
        try writer.writeAll(description);
        return clap.help(writer, clap.Help, &params, .{});
    }
    if (res.args.dir) |d| debug.print("--dir = {s}\n", .{d});
    for (res.positionals, 0..) |p, i| debug.print("positional_{} = {s}\n", .{ i, p });

    const parsed_fest = readConfig(allocator, frankenfest_filename) catch |err| switch (err) {
        error.FileNotFound => {
            debug.print("File not found: ./frankenfest.json\n", .{});
            return err;
        },
        else => {
            std.debug.panic("Unknown error: {}\n", .{err});
            return err;
        },
    };
    defer parsed_fest.deinit();
    const frankenfest = parsed_fest.value;

    try stdout.print("{}\n", .{frankenfest});

    try stdout_buffer.flush();
}

fn readConfig(allocator: Allocator, path: []const u8) !std.json.Parsed(Frankenfest) {
    // TODO: handle error, like file not found
    const data = try std.fs.cwd().readFileAlloc(allocator, path, 512);
    defer allocator.free(data);
    return std.json.parseFromSlice(Frankenfest, allocator, data, .{ .allocate = .alloc_always });
}

const Frankenfest = struct {
    project_name: []const u8,
};

const Config = struct {
    frankenfest_path: []const u8,
    commands: []Commands,
};

const Commands = enum {
    run_test,
    run_build,
    run_lint,
    run_format,
    run_proc,
};

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
