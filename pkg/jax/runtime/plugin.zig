const std = @import("std");
const jax = @import("jax");
const builtin = @import("builtin");

pub const Plugin = struct {
    lib: NativeLib,
    api: *const jax.pjrt.Api,

    pub fn init(path: []const u8) !Plugin {
        var lib = try NativeLib.open(path);
        errdefer lib.close();
        const api = getPjrtApi(&lib) orelse {
            lib.close();
            return error.NoPjrtApi;
        };
        return Plugin{ .lib = lib, .api = api };
    }

    pub fn deinit(self: *Plugin) void {
        self.lib.close();
    }
};

fn getPjrtApi(lib: *NativeLib) ?*const jax.pjrt.Api {
    const func = lib.lookup(*const fn () callconv(.c) *const jax.pjrt.Api, "GetPjrtApi") orelse return null;
    return func();
}

const NativeLib = if (builtin.os.tag == .windows)
    WindowsLib
else
    PosixLib;

const PosixLib = struct {
    inner: std.DynLib,

    fn open(path: []const u8) !PosixLib {
        return PosixLib{ .inner = try std.DynLib.open(path) };
    }

    fn close(self: *PosixLib) void {
        self.inner.close();
    }

    fn lookup(self: *PosixLib, comptime T: type, name: [:0]const u8) ?T {
        return self.inner.lookup(T, name);
    }
};

const WindowsLib = struct {
    const windows = std.os.windows;

    module: ?windows.HMODULE,

    fn open(path: []const u8) !WindowsLib {
        const path_w = try std.unicode.wtf8ToWtf16LeAllocZ(std.heap.page_allocator, path);
        defer std.heap.page_allocator.free(path_w);
        const module = LoadLibraryW(path_w.ptr) orelse {
            switch (windows.GetLastError()) {
                .MOD_NOT_FOUND => return error.FileNotFound,
                .INVALID_PARAMETER => unreachable,
                else => |err| return windows.unexpectedError(err),
            }
        };
        return WindowsLib{ .module = module };
    }

    fn close(self: *WindowsLib) void {
        if (self.module) |m| _ = FreeLibrary(m);
    }

    fn lookup(self: *WindowsLib, comptime T: type, name: [:0]const u8) ?T {
        const module = self.module orelse return null;
        const proc = GetProcAddress(module, name) orelse return null;
        return @ptrCast(@as(*const anyopaque, @ptrCast(proc)));
    }
};

pub extern "kernel32" fn LoadLibraryW(lpLibFileName: [*:0]const u16) callconv(.winapi) ?std.os.windows.HMODULE;
pub extern "kernel32" fn GetProcAddress(hModule: std.os.windows.HMODULE, lpProcName: [*:0]const u8) callconv(.winapi) ?std.os.windows.FARPROC;
pub extern "kernel32" fn FreeLibrary(hLibModule: std.os.windows.HMODULE) callconv(.winapi) std.os.windows.BOOL;
