const std = @import("std");

const c = @cImport({
    @cInclude("conway_life.h");
});

pub fn life(width: u16, height: u16) void {
    c.conway_life(width, height);
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}
