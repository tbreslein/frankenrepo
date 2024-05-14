const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const stdout_file = std.io.getStdOut().writer();
    var bw = std.io.bufferedWriter(stdout_file);
    const stdout = bw.writer();

    try stdout.print("Running Frankenrepo...\n", .{});

    const parsed = try readConfig(allocator, "./frankenfest.json");
    defer parsed.deinit();

    const config = parsed.value;
    try stdout.print("{s}", .{config.name});

    try bw.flush();
}

fn readConfig(allocator: Allocator, path: []const u8) !std.json.Parsed(Config) {
    // TODO: handle error, like file not found
    const data = try std.fs.cwd().readFileAlloc(allocator, path, 512);
    defer allocator.free(data);
    return std.json.parseFromSlice(Config, allocator, data, .{ .allocate = .alloc_always });
}

const Config = struct {
    name: []const u8,
};

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
