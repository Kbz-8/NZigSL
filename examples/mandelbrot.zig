const std = @import("std");
const nzsl = @import("nzigsl");

pub fn main() !void {
    const module = try nzsl.parser.parseFromFile("examples/mandelbrot.nzsl");
    defer module.deinit();

    const params = try nzsl.BackendParameters.init();
    defer params.deinit();
    params.setDebugLevel(.full);

    const writer = try nzsl.GlslWriter.init();
    defer writer.deinit();

    const writer_params = try nzsl.GlslWriter.Parameters.init();
    defer writer_params.deinit();

    const output = try writer.generate(module, params, writer_params);
    defer output.deinit();

    std.log.debug("Generated code: \n{s}", .{output.getCode()});
}
