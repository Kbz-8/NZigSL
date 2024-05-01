const cnzsl = @import("nzsl-c.zig");
const nzsl = @import("lib.zig");
const std = @import("std");

pub const ShaderStageType = enum(cnzsl.nzslShaderStageType) {
    compute = cnzsl.NZSL_STAGE_COMPUTE,
    fragment = cnzsl.NZSL_STAGE_FRAGMENT,
    vertex = cnzsl.NZSL_STAGE_VERTEX,
};

pub const GlslWriter = struct {
    instance: *cnzsl.nzslGlslWriter,

    pub fn create() GlslWriter {
        return .{.instance = cnzsl.nzslGlslWriterCreate() orelse unreachable};
    }

    pub fn release(self: GlslWriter) void {
        cnzsl.nzslGlslWriterDestroy(self.instance);
    }

    pub fn generate(self: GlslWriter, module: nzsl.Module, bindingMapping: GlslBindingMapping, states: nzsl.WriterStates) !GlslOutput {
        var output: ?*cnzsl.nzslGlslOutput = null;

        output = cnzsl.nzslGlslWriterGenerate(self.instance, module.instance, bindingMapping.instance, states.instance);

        if(output == null) {
            std.log.err("Failed to generate glsl output: {s}", .{ self.getLastError() });

            return error.FailedToGenerateGlsl;
        }

        return .{.instance = output orelse unreachable};
    }

    pub fn generateStage(self: GlslWriter, stage: ShaderStageType, module: nzsl.Module, bindingMapping: GlslBindingMapping, states: nzsl.WriterStates) !GlslOutput {
        var output: ?*cnzsl.nzslGlslOutput = null;

        output = cnzsl.nzslGlslWriterGenerateStage(@intFromEnum(stage), self.instance, module.instance, bindingMapping.instance, states.instance);

        if(output == null) {
            std.log.err("Failed to generate glsl output: {s}", .{ self.getLastError() });

            return error.FailedToGenerateGlsl;
        }

        return .{.instance = output orelse unreachable};
    }

    pub fn getLastError(self: GlslWriter) [*c]const u8 {
        return cnzsl.nzslGlslWriterGetLastError(self.instance);
    }
};

pub const GlslBindingMapping = struct {
    instance: *cnzsl.nzslGlslBindingMapping,

    pub fn create() GlslBindingMapping {
        return .{.instance = cnzsl.nzslGlslBindingMappingCreate() orelse unreachable};
    }

    pub fn release(self: GlslBindingMapping) void {
        cnzsl.nzslGlslBindingMappingDestroy(self.instance);
    }

    pub fn setBinding(self: GlslBindingMapping, setIndex: u32, bindingIndex: u32, glBinding: c_uint) void {
        cnzsl.nzslGlslBindingMappingSetBinding(self.instance, setIndex, bindingIndex, glBinding);
    }

};

pub const GlslOutput = struct {
    instance: *cnzsl.nzslGlslOutput,

    pub fn release(self: GlslOutput) void {
        cnzsl.nzslGlslOutputDestroy(self.instance);
    }

    pub fn getCode(self: GlslOutput) []const u8 {
        var size: usize = undefined;
        const code = cnzsl.nzslGlslOutputGetCode(self.instance, &size);

        return code[0..size];
    }

    /// Return texture binding in output or -1 if binding doesn't exists
    pub fn getExplicitTextureBinding(self: GlslOutput, bindingName: [*c]const u8) c_int {
        return cnzsl.nzslGlslOutputGetExplicitTextureBinding(self.instance, bindingName);
    }

    /// Return uniform binding in output or -1 if binding doesn't exists
    pub fn getExplicitUniformBlockBinding(self: GlslOutput, bindingName: [*c]const u8) c_int {
        return cnzsl.nzslGlslOutputGetExplicitUniformBlockBinding(self.instance, bindingName);
    }

    pub fn getUsesDrawParameterBaseInstanceUniform(self: GlslOutput) c_int {
        return cnzsl.nzslGlslOutputGetUsesDrawParameterBaseInstanceUniform(self.instance);
    }

    pub fn getUsesDrawParameterBaseVertexUniform(self: GlslOutput) c_int {
        return cnzsl.nzslGlslOutputGetUsesDrawParameterBaseVertexUniform(self.instance);
    }

    pub fn getUsesDrawParameterDrawIndexUniform(self: GlslOutput) c_int {
        return cnzsl.nzslGlslOutputGetUsesDrawParameterDrawIndexUniform(self.instance);
    }
};