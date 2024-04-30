// const cnzsl = @cImport({
//     @cInclude("CNZSL/CNZSL.h");
// });
const std = @import("std");
const cnzsl = @import("nzsl-c.zig");

pub const DebugLevel = cnzsl.nzslDebugLevel;
pub const OptionHash = cnzsl.nzslOptionHash;

pub fn parseSource(source: []const u8) !Module {
    return parseSourceWithFilePath(source, "");
}

pub fn parseSourceWithFilePath(source: []const u8, filePath: []const u8) !Module {
    const module = Module.create();

    if(cnzsl.nzslParserParseSourceWithFilePath(module.instance, source.ptr, source.len, filePath.ptr, filePath.len) != 0) {
        defer module.release();
        std.log.err("Error while parsing source({s}): {s}", .{ filePath, module.getLastError() });

        return error.FailedToParse;
    }

    return module;
}

pub fn parseFromFile(filePath: []const u8) !Module {
    const module = Module.create();

    if(cnzsl.nzslParserParseFromFile(module.instance, filePath.ptr, filePath.len) != 0) {
        defer module.release();
        std.log.err("Error while parsing source: {s}", .{ module.getLastError() });

        return error.FailedToParse;
    }

    return module;
}

pub const Module = struct {
    instance: *cnzsl.nzslModule,

    pub fn create() Module {
        return .{.instance = cnzsl.nzslModuleCreate() orelse unreachable};
    }

    pub fn release(self: Module) void {
        cnzsl.nzslModuleDestroy(self.instance);
    }

    pub fn getLastError(self: Module) [*c]const u8 {
        return cnzsl.nzslModuleGetLastError(self.instance);
    }
};

pub const GlslWriter = struct {
    instance: *cnzsl.nzslGlslWriter,

    pub fn create() GlslWriter {
        return .{.instance = cnzsl.nzslGlslWriterCreate() orelse unreachable};
    }

    pub fn release(self: GlslWriter) void {
        cnzsl.nzslGlslWriterDestroy(self.instance);
    }

    pub fn generate(self: GlslWriter, module: Module, bindingMapping: GlslBindingMapping) !GlslOutput {
        var output: ?*cnzsl.nzslGlslOutput = null;

        output = cnzsl.nzslGlslWriterGenerate(self.instance, module.instance, bindingMapping.instance, null);

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
};

pub fn hashOption(str: [*c]const u8) OptionHash {
    return cnzsl.nzslHashOption(str);
}

pub const WriterStates = struct {
    instance: *cnzsl.nzslWriterStates,

    pub fn create() WriterStates {
        return .{.instance = cnzsl.nzslWriterStatesCreate() orelse unreachable};
    }

    pub fn enableOptimization(self: WriterStates, enable: bool) void {
        cnzsl.nzslWriterStatesEnableOptimization(self.instance, enable);
    }
    pub fn enableSanitization(self: WriterStates, enable: bool) void {
        cnzsl.nzslWriterStatesEnableSanitization(self.instance, enable);
    }
    pub fn setDebugLevel(self: WriterStates, debugLevel: DebugLevel) void {
        cnzsl.nzslWriterStatesSetDebugLevel(self.instance, debugLevel);
    }
    pub fn setOption(self: WriterStates, optionHash: OptionHash, value: anytype) void {
        switch (@TypeOf(value)) {
            inline bool => cnzsl.nzslWriterStatesSetOption_bool(self.instance, optionHash, @intFromBool(value)),
            inline cnzsl.nzslBool => cnzsl.nzslWriterStatesSetOption_bool(self.instance, optionHash, value),
            inline [2]bool, [2]bool, [2]cnzsl.nzslBool => cnzsl.nzslWriterStatesSetOption_vec2bool(self.instance, optionHash, value.ptr),
            inline [3]bool, [3]cnzsl.nzslBool => cnzsl.nzslWriterStatesSetOption_vec3bool(self.instance, optionHash, value.ptr),
            inline [4]bool, [4]cnzsl.nzslBool => cnzsl.nzslWriterStatesSetOption_vec4bool(self.instance, optionHash, value.ptr),
            inline comptime_float, f32 => cnzsl.nzslWriterStatesSetOption_f32(self.instance, optionHash, value),
            inline [2]f32 => cnzsl.nzslWriterStatesSetOption_vec2f32(self.instance, optionHash, value.ptr),
            inline [3]f32 => cnzsl.nzslWriterStatesSetOption_vec3f32(self.instance, optionHash, value.ptr),
            inline [4]f32 => cnzsl.nzslWriterStatesSetOption_vec4f32(self.instance, optionHash, value.ptr),
            inline comptime_int, i32 => cnzsl.nzslWriterStatesSetOption_i32(self.instance, optionHash, value),
            inline [2]i32 => cnzsl.nzslWriterStatesSetOption_vec2i32(self.instance, optionHash, value.ptr),
            inline [3]i32 => cnzsl.nzslWriterStatesSetOption_vec3i32(self.instance, optionHash, value.ptr),
            inline [4]i32 => cnzsl.nzslWriterStatesSetOption_vec4i32(self.instance, optionHash, value.ptr),
            inline u32 => cnzsl.nzslWriterStatesSetOption_u32(self.instance, optionHash, value),
            inline [2]u32 => cnzsl.nzslWriterStatesSetOption_vec2u32(self.instance, optionHash, value.ptr),
            inline [3]u32 => cnzsl.nzslWriterStatesSetOption_vec3u32(self.instance, optionHash, value.ptr),
            inline [4]u32 => cnzsl.nzslWriterStatesSetOption_vec4u32(self.instance, optionHash, value.ptr),
            else => std.debug.panic("Unsupported type {}", .{@TypeOf(value)})
        }
    }

    pub fn release(self: WriterStates) void {
        cnzsl.nzslWriterStatesDestroy(self.instance);
    }
};