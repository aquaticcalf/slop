const std = @import("std");
const slop = @import("slop");

test "add from lib" {
    try std.testing.expectEqual(@as(i32, 6), slop.add(2, 4));
}
