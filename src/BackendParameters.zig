const std = @import("std");
const DebugLevel = @import("lib.zig").DebugLevel;
const OptionHash = @import("lib.zig").OptionHash;
const FilesystemModuleResolver = @import("lib.zig").FilesystemModuleResolver;
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
    cnzsl.nzslBackendParametersEnableDeadCodeRemoval(self.instance, @intFromBool(enable));
}

pub fn enableOptimization(self: Self, enable: bool) void {
    cnzsl.nzslBackendParametersEnableOptimization(self.instance, @intFromBool(enable));
}

pub fn enableResolving(self: Self, enable: bool) void {
    cnzsl.nzslBackendParametersEnableResolving(self.instance, @intFromBool(enable));
}

pub fn enableTargetRequired(self: Self, enable: bool) void {
    cnzsl.nzslBackendParametersEnableTargetRequired(self.instance, @intFromBool(enable));
}

pub fn enableValidation(self: Self, enable: bool) void {
    cnzsl.nzslBackendParametersEnableValidation(self.instance, @intFromBool(enable));
}

pub fn setDebugLevel(self: Self, debug_level: DebugLevel) void {
    cnzsl.nzslBackendParametersSetDebugLevel(self.instance, @intFromEnum(debug_level));
}

pub fn SetModuleResolverFilesystem(self: Self, filesystem_module_resolver: FilesystemModuleResolver) void {
    cnzsl.nzslBackendParametersSetModuleResolver_Filesystem(@ptrCast(self.instance), @ptrCast(filesystem_module_resolver.instance));
}

pub fn setOption(self: Self, hash: OptionHash, value: anytype) !void {
    const T = @TypeOf(value);
    switch (@typeInfo(T)) {
        .vector => |v| try self.setOption(hash, @as([v.len]v.child, value)),
        .float, .int, .comptime_float, .comptime_int, .bool => try self.setOption(hash, [1]T{value}),
        .array => |a| {
            const sanitized_value, const sanitized_primitive_name = switch (@typeInfo(a.child)) {
                .bool => blk: {
                    var new_array: [a.len]c_int = undefined;
                    for (value, 0..a.len) |v, i| {
                        new_array[i] = @intFromBool(v);
                    }
                    break :blk .{ new_array, "bool" };
                },
                .float => |f| if (f.bits == 32) .{ value, @typeName(a.child) } else return error.Not32BitsFloat,
                .int => |i| if (i.bits == 32) .{ value, @typeName(a.child) } else return error.Not32BitsInt,
                .comptime_float => .{ value, "f32" },
                .comptime_int => .{ value, "i32" },
                else => return error.UnhandledType,
            };

            const type_name, const c_value = switch (a.len) {
                1 => .{ "" ++ sanitized_primitive_name, sanitized_value[0] },
                2...4 => .{ "vec" ++ [_]u8{'0' + a.len} ++ sanitized_primitive_name, @as([*c]const @TypeOf(sanitized_value[0]), @ptrCast(&sanitized_value)) },
                else => return error.UnhandledArrayOrVectorSize,
            };

            @call(.auto, @field(cnzsl, "nzslBackendParametersSetOption_" ++ type_name), .{ self.instance, hash, c_value });
        },
        else => return error.UnhandledType,
    }
}

test "init" {
    const params = try init();
    defer params.deinit();
}

test "valid setOption" {
    const params = try init();
    defer params.deinit();

    const primitive_types = [_]type{
        f32,
        i32,
        u32,
        bool,
    };

    inline for (1..4) |i| {
        inline for (primitive_types) |T| {
            const value: T = undefined;
            if (i == 1) {
                try params.setOption(0, value);
            } else {
                const array = [_]T{value} ** i;
                const vector: @Vector(i, T) = array;
                try params.setOption(0, vector);
                try params.setOption(0, array);
            }
        }
    }
}
