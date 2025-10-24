const std = @import("std");
const DebugLevel = @import("lib.zig").DebugLevel;
const OptionHash = @import("lib.zig").OptionHash;
const cnzsl = @cImport({
    @cInclude("CNZSL/CNZSL.h");
});

const Self = @This();

instance: *cnzsl.nzslBackendParameters,

pub fn init() !Self {
    const cparameters = cnzsl.nzslBackendParametersCreate() orelse return error.NullPointer;
    return .{
        .instance = cparameters,
    };
}

pub fn deinit(self: Self) void {
    cnzsl.nzslBackendParametersDestroy(self.instance);
}

pub fn enableDeadCodeRemoval(self: Self, enable: bool) void {
    cnzsl.nzslBackendParametersEnableDeadCodeRemoval(self.instance, enable);
}

pub fn enableOptimization(self: Self, enable: bool) void {
    cnzsl.nzslBackendParametersEnableOptimization(self.instance, enable);
}

pub fn enableResolving(self: Self, enable: bool) void {
    cnzsl.nzslBackendParametersEnableResolving(self.instance, enable);
}

pub fn enableTargetRequired(self: Self, enable: bool) void {
    cnzsl.nzslBackendParametersEnableTargetRequired(self.instance, enable);
}

pub fn enableValidation(self: Self, enable: bool) void {
    cnzsl.nzslBackendParametersEnableValidation(self.instance, enable);
}

pub fn setDebugLevel(self: Self, debug_level: DebugLevel) void {
    cnzsl.nzslBackendParametersSetDebugLevel(self.instance, @intFromEnum(debug_level));
}

//pub fn SetModuleResolver_Filesystem(self: Self, const nzslFilesystemModuleResolver* resolverPtr) void {
//}

pub fn setOption(self: Self, hash: OptionHash, value: anytype) void {
    const T = @TypeOf(value);
    switch (@typeInfo(T)) {
        .vector => |v| self.setOption(hash, @as([v.len]v.child, value)),
        .float, .int, .comptime_float, .comptime_int, .bool => self.setOption(hash, [1]T{value}),
        .array => |a| {
            const sanitized_value, const sanitized_primitive_name = switch (@typeInfo(a.child)) {
                .bool => blk: {
                    var new_array: [a.len]c_int = undefined;
                    for (value, 0..a.len) |v, i| {
                        new_array[i] = @intFromBool(v);
                    }
                    break :blk .{ new_array, "bool" };
                },
                .float => |f| if (f.bits != 32) @compileError("Unhandled float size (not 32 bits)") else .{ value, @typeName(a.child) },
                .int => |i| if (i.bits != 32) @compileError("Unhandled integer size (not 32 bits)") else .{ value, @typeName(a.child) },
                .comptime_float => .{ value, "f32" },
                .comptime_int => .{ value, "i32" },
                else => @compileError("Unhandled type"),
            };

            const type_name, const c_value = switch (a.len) {
                1 => .{ "" ++ sanitized_primitive_name, sanitized_value[0] },
                2...4 => .{ "vec" ++ [_]u8{'0' + a.len} ++ sanitized_primitive_name, @as([*c]const a.child, @ptrCast(&sanitized_value)) },
                else => @compileError("Unhandled array or vector size"),
            };

            @call(.auto, @field(cnzsl, "nzslBackendParametersSetOption_" ++ type_name), .{ self.instance, hash, c_value });
        },
        else => @compileError("Unhandled type"),
    }
}
