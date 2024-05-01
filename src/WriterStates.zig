const cnzsl = @import("nzsl-c.zig");
const nzsl = @import("lib.zig");
const std = @import("std");

pub fn vec(comptime T: type, comptime dim: usize) type {
    return [dim]T;
}

pub const vec2bool = vec(bool, 2);
pub const vec2nzslBool = vec(cnzsl.nzslBool, 2);
pub const vec3bool = vec(bool, 3);
pub const vec3nzslBool = vec(cnzsl.nzslBool, 3);
pub const vec4bool = vec(bool, 4);
pub const vec4nzslBool = vec(cnzsl.nzslBool, 4);
pub const vec2f32 = vec(f32, 2);
pub const vec3f32 = vec(f32, 3);
pub const vec4f32 = vec(f32, 4);
pub const vec2u32 = vec(u32, 2);
pub const vec3u32 = vec(u32, 3);
pub const vec4u32 = vec(u32, 4);
pub const vec2i32 = vec(i32, 2);
pub const vec3i32 = vec(i32, 3);
pub const vec4i32 = vec(i32, 4);

pub const DebugLevel = enum(cnzsl.nzslDebugLevel) {
    none = cnzsl.NZSL_DEBUG_NONE,
    full = cnzsl.NZSL_DEBUG_FULL,
    minimal = cnzsl.NZSL_DEBUG_MINIMAL,
    regular = cnzsl.NZSL_DEBUG_REGULAR,
};

pub const OptionHash = cnzsl.nzslOptionHash;

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
        cnzsl.nzslWriterStatesSetDebugLevel(self.instance, @intFromEnum(debugLevel));
    }
    pub fn setOption(self: WriterStates, optionHash: OptionHash, value: anytype) void {
        switch (@TypeOf(value)) {
        inline bool => cnzsl.nzslWriterStatesSetOption_bool(self.instance, optionHash, @intFromBool(value)),
        inline cnzsl.nzslBool => cnzsl.nzslWriterStatesSetOption_bool(self.instance, optionHash, value),
        inline vec2bool => {
            self.setOption(optionHash, vec2nzslBool{@intFromBool(value[0]), @intFromBool(value[1])});
        },
        inline vec2nzslBool => cnzsl.nzslWriterStatesSetOption_vec2bool(self.instance, optionHash, &value),
        inline vec3bool => {
            self.setOption(optionHash, vec3nzslBool{@intFromBool(value[0]), @intFromBool(value[1]), @intFromBool(value[2])});
        },
        inline vec3nzslBool => cnzsl.nzslWriterStatesSetOption_vec3bool(self.instance, optionHash, &value),
        inline vec4bool => {
            self.setOption(optionHash, vec4nzslBool{@intFromBool(value[0]), @intFromBool(value[1]), @intFromBool(value[2]), @intFromBool(value[3])});
        },
        inline vec4nzslBool => cnzsl.nzslWriterStatesSetOption_vec4bool(self.instance, optionHash, &value),
        inline comptime_float, f32 => cnzsl.nzslWriterStatesSetOption_f32(self.instance, optionHash, value),
        inline vec2f32 => cnzsl.nzslWriterStatesSetOption_vec2f32(self.instance, optionHash, &value),
        inline vec3f32 => cnzsl.nzslWriterStatesSetOption_vec3f32(self.instance, optionHash, &value),
        inline vec4f32 => cnzsl.nzslWriterStatesSetOption_vec4f32(self.instance, optionHash, &value),
        inline i32 => cnzsl.nzslWriterStatesSetOption_i32(self.instance, optionHash, value),
        inline comptime_int => {
            std.log.debug("/!\\ setOption with comptime_int defaults to i32 with value {} ", .{ value });
            cnzsl.nzslWriterStatesSetOption_i32(self.instance, optionHash, value);
        },
        inline vec2i32 => cnzsl.nzslWriterStatesSetOption_vec2i32(self.instance, optionHash, &value),
        inline vec3i32 => cnzsl.nzslWriterStatesSetOption_vec3i32(self.instance, optionHash, &value),
        inline vec4i32 => cnzsl.nzslWriterStatesSetOption_vec4i32(self.instance, optionHash, &value),
        inline u32 => cnzsl.nzslWriterStatesSetOption_u32(self.instance, optionHash, value),
        inline vec2u32 => cnzsl.nzslWriterStatesSetOption_vec2u32(self.instance, optionHash, &value),
        inline vec3u32 => cnzsl.nzslWriterStatesSetOption_vec3u32(self.instance, optionHash, &value),
        inline vec4u32 => cnzsl.nzslWriterStatesSetOption_vec4u32(self.instance, optionHash, &value),
        else => std.debug.panic("Unsupported type {}", .{@TypeOf(value)})
        }
    }

    pub fn release(self: WriterStates) void {
        cnzsl.nzslWriterStatesDestroy(self.instance);
    }
};