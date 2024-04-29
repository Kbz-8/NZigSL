//const nzsl = @cImport({
//    @cInclude("CNZSL/CNZSL.h");
//});
const std = @import("std");
const cnzsl = @import("cimport.zig");

pub fn parseSource(source: []const u8) !Module {
    const module = Module{.instance = null};

    if(cnzsl.nzslParserParseSource(module.instance, source.ptr, source.len) != 0) {
        defer module.release();
        std.log.err("Error while parsing source: {s}", .{ module.getLastError() });

        return error.FailedToParse;
    }

    return module;
}

pub fn parseSourceWithFilePath(source: []const u8, filePath: []const u8) !Module {
    const module: ?*cnzsl.nzslModule = null;

    if(cnzsl.nzslParserParseSourceWithFilePath(module, source.ptr, source.len, filePath.ptr, filePath.len) != 0) {
        defer cnzsl.nzslModuleDestroy(module);
        std.log.err("Error while parsing source: {s}", .{ module.getLastError() });

        return error.FailedToParse;
    }

    if (module == null) {
        std.log.err("Error while parsing source: Unknown error", .{ });
        return error.FailedToParse;
    }

    return .{.instance = module};
}

pub fn parseFromFile(filePath: []const u8) !Module {
    const module: ?*cnzsl.nzslModule = null;

    if(cnzsl.nzslParserParseFromFile(module, filePath.ptr, filePath.len) != 0) {
        defer cnzsl.nzslModuleDestroy(module);
        std.log.err("Error while parsing source: {s}", .{ cnzsl.nzslModuleGetLastError(module) });

        return error.FailedToParse;
    }

    if (module == null) {
        std.log.err("Error while parsing source: Unknown error", .{ });
        return error.FailedToParse;
    }

    return .{.instance = module};
}

pub const Module = struct {
    instance: *cnzsl.nzslModule,

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

    pub fn generate(self: GlslWriter, module: Module) !GlslOutput {
        var output: ?*cnzsl.nzslGlslOutput = null;

        output = cnzsl.nzslGlslWriterGenerate(self.instance, module.instance, null, null);

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

pub const GlslOutput = struct {
    instance: *cnzsl.nzslGlslOutput,

    pub fn release(self: GlslOutput) void {
        cnzsl.nzslGlslOutputDestroy(self.instance);
    }
};
