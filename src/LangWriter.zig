const cnzsl = @import("nzsl-c.zig");
const nzsl = @import("lib.zig");
const std = @import("std");

pub const LangWriter = struct {
    instance: *cnzsl.nzslLangWriter,

    pub fn create() LangWriter {
        return .{.instance = cnzsl.nzslLangWriterCreate() orelse unreachable};
    }

    pub fn release(self: LangWriter) void {
        cnzsl.nzslLangWriterDestroy(self.instance);
    }

    pub fn getLastError(self: LangWriter) [*c]const u8 {
        return cnzsl.nzslLangWriterGetLastError(self.instance);
    }

    pub fn generate(self: LangWriter, module: nzsl.Module, states: nzsl.WriterStates) LangOutput {
        var output: ?*cnzsl.nzslLangOutput = null;

        output = cnzsl.nzslLangWriterGenerate(self.instance, module.instance, states.instance);

        if(output == null) {
            std.log.err("Failed to generate lang output: {s}", .{ self.getLastError() });

            return error.FailedToGenerateLang;
        }

        return .{.instance = output orelse unreachable};
    }

};

pub const LangOutput = struct {
    instance: *cnzsl.nzslLangOutput,

    pub fn release(self: LangOutput) void {
        cnzsl.nzslLangOutputDestroy(self.instance);
    }

    pub fn getCode(self: LangOutput) []const u8 {
        var size: usize = undefined;
        const code = cnzsl.nzslLangOutputGetCode(self.instance, &size);

        return code[0..size];
    }
};
