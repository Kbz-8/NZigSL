const std = @import("std");
const Module = @import("Module.zig");
const cnzsl = @cImport({
    @cInclude("CNZSL/CNZSL.h");
});

const Self = @This();

instance: *cnzsl.nzslSerializer,

pub fn init() !Self {
    const cserializer = cnzsl.nzslSerializerCreate() orelse return error.NullPointer;
    return .{
        .instance = cserializer,
    };
}

pub fn deinit(self: Self) void {
    cnzsl.nzslSerializerDestroy(self.instance);
}

pub fn serializeShader(self: Self, module: Module) !void {
    if (cnzsl.nzslSerializeShader(self.instance, @ptrCast(module.instance)) == 0) {
        return error.FailedToSerializeShader;
    }
}

pub fn getData(self: Self) []const u8 {
    var size: usize = undefined;
    const code: [*c]const u8 = @ptrCast(cnzsl.nzslSerializerGetData(self.instance, &size));
    return code[0..size];
}

pub fn getLastError(self: Self) ![]const u8 {
    const err = cnzsl.nzslSerializerGetLastError(@ptrCast(self.instance)) orelse return error.NullPointer;
    return std.mem.span(err);
}
