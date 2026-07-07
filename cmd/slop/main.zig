const std = @import("std");
const slop = @import("slop");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var buf: [0x100]u8 = undefined;
    var w = std.Io.File.stdout().writer(io, &buf);
    const out = &w.interface;
    try out.print("2 + 4 = {d}", .{slop.add(2, 4)});
    try out.flush();
}
