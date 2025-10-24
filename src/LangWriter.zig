const std = @import("std");
const Module = @import("Module.zig");
const cnzsl = @cImport({
    @cInclude("CNZSL/CNZSL.h");
});

const Self = @This();

instance: *cnzsl.nzslLangWriter,

pub fn init() !Self {
    const cwriter = cnzsl.nzslLangWriterCreate() orelse return error.NullPointer;
    return .{
        .instance = cwriter,
    };
}

pub fn deinit(self: Self) void {
    cnzsl.nzslLangWriterDestroy(self.instance);
}

pub fn getLastError(self: Self) ![]const u8 {
    const err = cnzsl.nzslLangWriterGetLastError(self.instance) orelse return error.NullPointer;
    return std.mem.span(err);
}

pub fn generate(self: Self, module: Module) !Output {
    const output = cnzsl.nzslLangWriterGenerate(self.instance, @ptrCast(module.instance)) orelse return error.FailedToGenerateLang;
    return .{
        .instance = output,
    };
}

pub const Output = struct {
    const InnerSelf = @This();

    instance: *cnzsl.nzslLangOutput,

    pub fn deinit(self: InnerSelf) void {
        cnzsl.nzslLangOutputDestroy(self.instance);
    }

    pub fn getCode(self: InnerSelf) []const u8 {
        var size: usize = undefined;
        const code = cnzsl.nzslLangOutputGetCode(self.instance, &size);
        return code[0..size];
    }
};
