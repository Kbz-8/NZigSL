const cnzsl = @import("nzsl-c.zig");

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