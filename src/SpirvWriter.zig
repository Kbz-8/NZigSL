const std = @import("std");
const Module = @import("Module.zig");
const BackendParameters = @import("BackendParameters.zig");
const cnzsl = @cImport({
    @cInclude("CNZSL/CNZSL.h");
});

const Self = @This();

instance: *cnzsl.nzslSpirvWriter,

pub fn init() !Self {
    const cwriter = cnzsl.nzslSpirvWriterCreate() orelse return error.NullPointer;
    return .{
        .instance = cwriter,
    };
}

pub fn deinit(self: Self) void {
    cnzsl.nzslSpirvWriterDestroy(self.instance);
}

pub fn getLastError(self: Self) ![]const u8 {
    const err = cnzsl.nzslSpirvWriterGetLastError(self.instance) orelse return error.NullPointer;
    return std.mem.span(err);
}

pub fn setEnv(self: Self, env: Environment) void {
    const SpirvEnv = extern struct {
        spv_major_version: u32,
        spv_minor_version: u32,
    };
    const cenv: SpirvEnv = .{
        .spv_major_version = @intCast(env.spv_version.major),
        .spv_minor_version = @intCast(env.spv_version.minor),
    };
    return cnzsl.nzslSpirvWriterSetEnv(self.instance, @ptrCast(&cenv));
}

pub fn generate(self: Self, module: Module, backend_parameters: BackendParameters) !Output {
    const output = cnzsl.nzslSpirvWriterGenerate(self.instance, @ptrCast(module.instance), @ptrCast(backend_parameters.instance)) orelse return error.FailedToGenerateSpirv;
    return .{
        .instance = output,
    };
}

pub const Environment = struct {
    spv_version: std.SemanticVersion,
};

pub const Output = struct {
    const InnerSelf = @This();

    instance: *cnzsl.nzslSpirvOutput,

    pub fn deinit(self: InnerSelf) void {
        cnzsl.nzslSpirvOutputDestroy(self.instance);
    }

    pub fn getCode(self: InnerSelf) []const u32 {
        var size: usize = undefined;
        const code = cnzsl.nzslSpirvOutputGetSpirv(self.instance, &size);
        return code[0..size];
    }
};
