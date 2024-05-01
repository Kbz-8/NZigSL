const std= @import("std");
const nzsl = @import("nzslzig");

pub fn main() !void {
    const mandelbrotModule = try nzsl.parseFromFile("examples/mandelbrot.nzsl");
    defer mandelbrotModule.release();

    const glslWriter = nzsl.GlslWriter.create();
    defer glslWriter.release();

    const state = nzsl.WriterStates.create();
    defer state.release();

    state.setDebugLevel(.full);

    const mappings = nzsl.GlslBindingMapping.create();
    defer mappings.release();

    const output = try glslWriter.generate(mandelbrotModule, mappings, state);
    defer output.release();

    std.log.debug("Generated code: \n{s}", .{ output.getCode() });

}