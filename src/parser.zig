const std = @import("std");
const cnzsl = @cImport({
    @cInclude("CNZSL/CNZSL.h");
});
const Module = @import("Module.zig");

pub fn parseSource(source: []const u8) !Module {
    return parseSourceWithFilePath(source, "");
}

pub fn parseSourceWithFilePath(source: []const u8, filePath: []const u8) !Module {
    const module = try Module.init();
    errdefer module.deinit();
    if (cnzsl.nzslParserParseSourceWithFilePath(@ptrCast(module.instance), source.ptr, source.len, filePath.ptr, filePath.len) != 0) {
        return error.FailedToParse;
    }
    return module;
}

pub fn parseFromFile(filePath: []const u8) !Module {
    const module = try Module.init();
    errdefer module.deinit();
    if (cnzsl.nzslParserParseFromFile(@ptrCast(module.instance), filePath.ptr, filePath.len) != 0) {
        return error.FailedToParse;
    }
    return module;
}
