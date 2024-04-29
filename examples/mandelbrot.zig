const std= @import("std");
const nzsl = @import("nzslzig");

pub fn main() !void {
    const mandelbrotModule = try nzsl.parseFromFile("./mandelbrot.nzsl");
    defer mandelbrotModule.release();

    const glslWriter = nzsl.GlslWriter.create();
    defer glslWriter.release();

    const output = try glslWriter.generate(mandelbrotModule);
    defer output.release();

}