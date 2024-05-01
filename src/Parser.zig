const cnzsl = @import("nzsl-c.zig");
const nzsl = @import("lib.zig");
const std = @import("std");

pub fn parseSource(source: []const u8) !nzsl.Module {
    return parseSourceWithFilePath(source, "");
}

/// Parse a NZSL source code and stores it inside a nzslModule
/// In case of failure, a negative value is returned and an error code is set
///
/// @param module pointer to a
/// @param source pointer to NZSL source
/// @param sourceLen length of source in characters
/// @param filePath used when reporting errors
/// @param filePathLen length of filePath in characters
/// @return 0 if parsing succeeded and a negative value in case of failure
///
/// @see nzslModuleGetLastError
pub fn parseSourceWithFilePath(source: []const u8, filePath: []const u8) !nzsl.Module {
    const module = nzsl.Module.create();

    if(cnzsl.nzslParserParseSourceWithFilePath(module.instance, source.ptr, source.len, filePath.ptr, filePath.len) != 0) {
        defer module.release();
        std.log.err("Error while parsing source({s}): {s}", .{ filePath, module.getLastError() });

        return error.FailedToParse;
    }

    return module;
}

pub fn parseFromFile(filePath: []const u8) !nzsl.Module {
    const module = nzsl.Module.create();

    if(cnzsl.nzslParserParseFromFile(module.instance, filePath.ptr, filePath.len) != 0) {
        defer module.release();
        std.log.err("Error while parsing source: {s}", .{ module.getLastError() });

        return error.FailedToParse;
    }

    return module;
}