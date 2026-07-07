const types = @import("types.zig");

pub const ExtensionBase = types.ExtensionBase;
pub const CopyToDeviceStream = types.CopyToDeviceStream;
pub const Chunk = types.Chunk;
pub const Event = types.Event;

pub const AddChunkArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    stream: ?*CopyToDeviceStream,
    chunk: ?*Chunk,
    transfer_complete: ?*Event,
};

pub const TotalBytesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    stream: ?*CopyToDeviceStream,
    total_bytes: i64,
};

pub const GranuleSizeArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    stream: ?*CopyToDeviceStream,
    granule_size_in_bytes: i64,
};

pub const CurrentBytesArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    stream: ?*CopyToDeviceStream,
    current_bytes: i64,
};

pub const DestroyArgs = extern struct {
    struct_size: usize,
    extension_start: ?*ExtensionBase,
    stream: ?*CopyToDeviceStream,
};
