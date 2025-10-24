const std = @import("std");
const cnzsl = @cImport({
    @cInclude("CNZSL/CNZSL.h");
});

const Self = @This();

instance: *cnzsl.nzslModule,

pub fn init() !Self {
    const cmodule = cnzsl.nzslModuleCreate() orelse return error.NullPointer;
    return .{
        .instance = cmodule,
    };
}

pub fn deinit(self: Self) void {
    cnzsl.nzslModuleDestroy(@ptrCast(self.instance));
}

pub fn getLastError(self: Self) ![]const u8 {
    const err = cnzsl.nzslModuleGetLastError(@ptrCast(self.instance)) orelse return error.NullPointer;
    return std.mem.span(err);
}
