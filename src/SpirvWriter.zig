const cnzsl = @import("nzsl-c.zig");
const nzsl = @import("lib.zig");
const std = @import("std");

pub const SpirvWriterEnvironment = cnzsl.nzslSpirvWriterEnvironment;

pub const SpirvWriter = struct {
    instance: *cnzsl.nzslSpirvWriter,

    pub fn create() SpirvWriter {
        return .{.instance = cnzsl.nzslSpirvWriterCreate() orelse unreachable};
    }

    pub fn release(self: SpirvWriter) void {
        cnzsl.nzslSpirvWriterDestroy(self.instance);
    }

    pub fn getLastError(self: SpirvWriter) [*c]const u8 {
        return cnzsl.nzslSpirvWriterGetLastError(self.instance);
    }

    pub fn setEnv(self: SpirvWriter, env: SpirvWriterEnvironment) void {
        return cnzsl.nzslSpirvWriterSetEnv(self.instance, env);
    }

    pub fn generate(self: SpirvWriter, module: nzsl.Module, states: nzsl.WriterStates) SpirvOutput {
        var output: ?*cnzsl.nzslSpirvOutput = null;

        output = cnzsl.nzslSpirvWriterGenerate(self.instance, module.instance, states.instance);

        if(output == null) {
            std.log.err("Failed to generate spirv output: {s}", .{ self.getLastError() });

            return error.FailedToGenerateSpirv;
        }

        return .{.instance = output orelse unreachable};
    }

};

pub const SpirvOutput = struct {
    instance: *cnzsl.nzslSpirvOutput,

    pub fn release(self: SpirvOutput) void {
        cnzsl.nzslSpirvOutputDestroy(self.instance);
    }

    pub fn getCode(self: SpirvOutput) []const u32 {
        var size: usize = undefined;
        const code = cnzsl.nzslSpirvOutputGetSpirv(self.instance, &size);

        return code[0..size];
    }
};
