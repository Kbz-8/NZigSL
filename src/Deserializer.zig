const std = @import("std");
const Module = @import("Module.zig");
const cnzsl = @cImport({
    @cInclude("CNZSL/CNZSL.h");
});

const Self = @This();

instance: *cnzsl.nzslDeserializer,

pub fn init(data: []const u8) !Self {
    const cdeserializer = cnzsl.nzslDeserializerCreate(@ptrCast(data), data.len) orelse return error.NullPointer;
    return .{
        .instance = cdeserializer,
    };
}

pub fn deinit(self: Self) void {
    cnzsl.nzslDeserializerDestroy(@ptrCast(self.instance));
}

pub fn deserializeShader(self: Self) !Module {
    const cmodule = cnzsl.nzslDeserializeShader(@ptrCast(self.instance)) orelse return error.NullPointer;
    return .{
        .instance = @ptrCast(cmodule),
    };
}

pub fn getLastError(self: Self) ![]const u8 {
    const err = cnzsl.nzslDeserializerGetLastError(@ptrCast(self.instance)) orelse return error.NullPointer;
    return std.mem.span(err);
}
