const std = @import("std");
const Module = @import("Module.zig");
const BackendParameters = @import("BackendParameters.zig");
const ShaderStageType = @import("lib.zig").ShaderStageType;
const cnzsl = @cImport({
    @cInclude("CNZSL/CNZSL.h");
});

const Self = @This();

instance: *cnzsl.nzslGlslWriter,

pub fn init() !Self {
    const cwriter = cnzsl.nzslGlslWriterCreate() orelse return error.NullPointer;
    return .{
        .instance = cwriter,
    };
}

pub fn deinit(self: Self) void {
    cnzsl.nzslGlslWriterDestroy(self.instance);
}

pub fn generate(self: Self, module: Module, backend_parameters: BackendParameters, parameters: Parameters) !Output {
    const output = cnzsl.nzslGlslWriterGenerate(self.instance, @ptrCast(module.instance), @ptrCast(backend_parameters.instance), @ptrCast(parameters.instance)) orelse return error.FailedToGenerateGlsl;
    return .{
        .instance = output,
    };
}

pub fn generateStage(self: Self, stage: ShaderStageType, module: Module, backend_parameters: BackendParameters, parameters: Parameters) !Output {
    const output = cnzsl.nzslGlslWriterGenerateStage(self.instance, @intFromEnum(stage), @ptrCast(module.instance), @ptrCast(backend_parameters.instance), @ptrCast(parameters.instance)) orelse return error.FailedToGenerateGlsl;
    return .{
        .instance = output,
    };
}

pub fn getLastError(self: Self) ![]const u8 {
    const err = cnzsl.nzslGlslWriterGetLastError(self.instance) orelse return error.NullPointer;
    return std.mem.span(err);
}

pub const Parameters = struct {
    const InnerSelf = @This();

    instance: *cnzsl.nzslGlslWriterParameters,

    pub fn init() !InnerSelf {
        const cparameters = cnzsl.nzslGlslWriterParametersCreate() orelse return error.NullPointer;
        return .{
            .instance = cparameters,
        };
    }

    pub fn deinit(self: InnerSelf) void {
        cnzsl.nzslGlslWriterParametersDestroy(self.instance);
    }

    pub fn setBindingMapping(self: InnerSelf, set_index: u32, binding_index: u32, gl_binding: u32) void {
        cnzsl.nzslGlslWriterParametersSetBindingMapping(self.instance, set_index, binding_index, @intCast(gl_binding));
    }

    pub fn setPushConstantBinding(self: InnerSelf, gl_binding: u32) void {
        cnzsl.nzslGlslWriterParametersSetPushConstantBinding(self.instance, @intCast(gl_binding));
    }
};

pub const Output = struct {
    const InnerSelf = @This();

    instance: *cnzsl.nzslGlslOutput,

    pub fn deinit(self: InnerSelf) void {
        cnzsl.nzslGlslOutputDestroy(self.instance);
    }

    pub fn getCode(self: InnerSelf) []const u8 {
        var size: usize = undefined;
        const code = cnzsl.nzslGlslOutputGetCode(self.instance, &size);
        return code[0..size];
    }

    pub fn getExplicitTextureBinding(self: InnerSelf, binding_name: [:0]const u8) i32 {
        const res = cnzsl.nzslGlslOutputGetExplicitTextureBinding(self.instance, binding_name);
        return if (res != -1) res else error.BindingNameNotFound;
    }

    pub fn getExplicitUniformBlockBinding(self: InnerSelf, binding_name: [:0]const u8) i32 {
        const res = cnzsl.nzslGlslOutputGetExplicitUniformBlockBinding(self.instance, binding_name);
        return if (res != -1) res else error.BindingNameNotFound;
    }

    pub fn usesDrawParameterBaseInstanceUniform(self: InnerSelf) bool {
        return cnzsl.nzslGlslOutputGetUsesDrawParameterBaseInstanceUniform(self.instance);
    }

    pub fn usesDrawParameterBaseVertexUniform(self: InnerSelf) bool {
        return cnzsl.nzslGlslOutputGetUsesDrawParameterBaseVertexUniform(self.instance);
    }

    pub fn usesDrawParameterDrawIndexUniform(self: InnerSelf) bool {
        return cnzsl.nzslGlslOutputGetUsesDrawParameterDrawIndexUniform(self.instance);
    }
};
