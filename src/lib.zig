// const cnzsl = @cImport({
//     @cInclude("CNZSL/CNZSL.h");
// });
const std = @import("std");
const cnzsl = @import("nzsl-c.zig");

pub usingnamespace @import("WriterStates.zig");
pub usingnamespace @import("GlslWriter.zig");
pub usingnamespace @import("SpirvWriter.zig");
pub usingnamespace @import("Module.zig");
pub usingnamespace @import("Parser.zig");
