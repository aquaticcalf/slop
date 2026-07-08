const pjrt = @import("jax").pjrt;

pub const DType = enum {
    invalid,
    pred,
    s8,
    s16,
    s32,
    s64,
    u8,
    u16,
    u32,
    u64,
    f16,
    f32,
    f64,
    bf16,
    c64,
    c128,
    f8e5m2,
    f8e4m3fn,
    f8e4m3b11fnuz,
    f8e5m2fnuz,
    f8e4m3fnuz,
    s4,
    u4,
    token,
    s2,
    u2,
    f8e4m3,
    f8e3m4,
    f8e8m0fnu,
    f4e2m1fn,
    s1,
    u1,

    pub fn toBufferType(self: DType) pjrt.BufferType {
        return @enumFromInt(@intFromEnum(self));
    }

    pub fn fromBufferType(bt: pjrt.BufferType) DType {
        return @enumFromInt(@intFromEnum(bt));
    }

    pub fn sizeInBytes(self: DType) usize {
        return switch (self) {
            .invalid => 0,
            .pred => 1,
            .s8, .u8, .f8e5m2, .f8e4m3fn, .f8e4m3b11fnuz, .f8e5m2fnuz, .f8e4m3fnuz, .f8e4m3, .f8e3m4, .f8e8m0fnu, .f4e2m1fn => 1,
            .s16, .u16, .f16, .bf16 => 2,
            .s32, .u32, .f32 => 4,
            .s64, .u64, .f64, .c64 => 8,
            .c128 => 16,
            .s4, .u4 => 1,
            .s2, .u2 => 1,
            .s1, .u1 => 1,
            .token => 0,
        };
    }
};

pub const Shape = struct {
    dims: []const i64,
    dtype: DType,

    pub fn numElements(self: Shape) usize {
        var n: usize = 1;
        for (self.dims) |d| n *= @as(usize, @intCast(d));
        return n;
    }

    pub fn sizeInBytes(self: Shape) usize {
        return self.numElements() * self.dtype.sizeInBytes();
    }
};
