const std = @import("std");
const Module = @import("Module.zig");
const cnzsl = @cImport({
    @cInclude("CNZSL/CNZSL.h");
});

const Self = @This();

instance: *cnzsl.nzslFilesystemModuleResolver,

pub fn init() !Self {
    const cfmr = cnzsl.nzslFilesystemModuleResolverCreate() orelse return error.NullPointer;
    return .{
        .instance = cfmr,
    };
}

pub fn deinit(self: Self) void {
    cnzsl.nzslFilesystemModuleResolverDestroy(@ptrCast(self.instance));
}

pub fn getLastError(self: Self) ![]const u8 {
    const err = cnzsl.nzslFilesystemModuleResolverGetLastError(self.instance) orelse return error.NullPointer;
    return std.mem.span(err);
}

pub fn registerDirectory(self: Self, source_path: []const u8) void {
    cnzsl.nzslFilesystemModuleResolverRegisterDirectory(@ptrCast(self.instance), source_path.ptr, source_path.len);
}

pub fn registerFile(self: Self, source_path: []const u8) void {
    cnzsl.nzslFilesystemModuleResolverRegisterFile(@ptrCast(self.instance), source_path.ptr, source_path.len);
}

pub fn registerModule(self: Self, module: Module) void {
    cnzsl.nzslFilesystemModuleResolverRegisterModule(@ptrCast(self.instance), @ptrCast(module.instance));
}

pub fn registerModuleFromSource(self: Self, source: []const u8) void {
    cnzsl.nzslFilesystemModuleResolverRegisterModuleFromSource(@ptrCast(self.instance), source.ptr, source.len);
}
