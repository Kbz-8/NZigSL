const std = @import("std");
const cnzsl = @cImport({
    @cInclude("CNZSL/CNZSL.h");
});

pub const ShaderStageType = enum(cnzsl.nzslShaderStageType) {
    compute = cnzsl.NZSL_STAGE_COMPUTE,
    fragment = cnzsl.NZSL_STAGE_FRAGMENT,
    vertex = cnzsl.NZSL_STAGE_VERTEX,
};

pub const DebugLevel = enum(cnzsl.nzslDebugLevel) {
    none = cnzsl.NZSL_DEBUG_NONE,
    full = cnzsl.NZSL_DEBUG_FULL,
    minimal = cnzsl.NZSL_DEBUG_MINIMAL,
    regular = cnzsl.NZSL_DEBUG_REGULAR,
};

pub const OptionHash = u32;

pub fn hashOption(str: [:0]const u8) !OptionHash {
    return cnzsl.nzslHashOption(str);
}

pub const BackendParameters = @import("BackendParameters.zig");
pub const Deserializer = @import("Deserializer.zig");
pub const FilesystemModuleResolver = @import("FilesystemModuleResolver.zig");
pub const GlslWriter = @import("GlslWriter.zig");
pub const LangWriter = @import("LangWriter.zig");
pub const Module = @import("Module.zig");
pub const parser = @import("parser.zig");
pub const Serializer = @import("Serializer.zig");
pub const SpirvWriter = @import("SpirvWriter.zig");
