const std= @import("std");
const nzsl = @import("nzslzig");

pub fn main() !void {
    const mandelbrotModule = try nzsl.parseFromFile("examples/mandelbrot.nzsl");
    defer mandelbrotModule.release();

    const glslWriter = nzsl.GlslWriter.create();
    defer glslWriter.release();

    const state = nzsl.WriterStates.create();
    defer state.release();

    state.setOption(nzsl.hashOption("foo"), 42);
    state.setOption(nzsl.hashOption("foo"), 42.3);
    state.setOption(nzsl.hashOption("foo"), true);
    state.setOption(nzsl.hashOption("foo"), .{true, false});
    state.setOption(nzsl.hashOption("foo"), .{12, 24});
    state.setOption(nzsl.hashOption("foo"), .{12.4, 24});

    const mappings = nzsl.GlslBindingMapping.create();
    defer mappings.release();

    const output = try glslWriter.generate(mandelbrotModule, mappings);
    defer output.release();

}