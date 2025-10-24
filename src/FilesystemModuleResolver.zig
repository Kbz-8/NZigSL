const std = @import("std");
const Module = @import("Module.zig");
const cnzsl = @cImport({
    @cInclude("CNZSL/CNZSL.h");
});

const Self = @This();

instance: *cnzsl.nzslFilesystemModuleResolver,

pub fn init() !Self {
    const cfmr = cnzsl.nzslFilesystemModuleResolverCreate() orelse error.NullPointer;
    return .{
        .instance = cfmr,
    };
}

pub fn deinit(self: Self) void {
    cnzsl.nzslFilesystemModuleResolverDestroy(@ptrCast(self.instance));
}
