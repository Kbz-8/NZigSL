const std = @import("std");

const Build = std.Build;
const Step = std.Build.Step;

pub const Libsource = enum {
    source,
    prebuild
};

// based on ziglua's build.zig

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *Build) void {
    // Remove the default install and uninstall steps
    b.top_level_steps = .{};

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libsource = b.option(Libsource, "libsource", "Use prebuild or compile from sources") orelse .source;
    const shared = b.option(bool, "shared", "Build shared library instead of static") orelse false;

    if (libsource == .prebuild) {
        std.debug.panic("Prebuild aren't available for now", .{});
    }

    // Zig module
    const nzslzig = b.addModule("nzslzig", .{
        .root_source_file = .{ .path = "src/lib.zig" },
    });

    const docs = b.addStaticLibrary(.{
        .name = "nzslzig",
        .root_source_file = .{ .path = "src/lib.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Expose build configuration to the nzslzig module
    const config = b.addOptions();
    config.addOption(Libsource, "libsource", libsource);
    nzslzig.addOptions("config", config);

    nzsldep: {
        const upstream = b.lazyDependency(if (libsource == .source) "nzsl_source" else break :nzsldep , .{}) orelse break :nzsldep;
        const nazaraUtils = b.lazyDependency("NazaraUtils", .{}) orelse break :nzsldep;
        const frozen = b.lazyDependency("frozen", .{}) orelse break :nzsldep;
        const fmt = b.lazyDependency("fmt", .{}) orelse break :nzsldep;
        const ordered_map = b.lazyDependency("ordered_map", .{}) orelse break :nzsldep;
        const fast_float = b.lazyDependency("fast_float", .{}) orelse break :nzsldep;

        const lib = switch (libsource) {
        .source => buildNzsl(b, target, optimize, upstream, nazaraUtils, frozen, fmt, ordered_map, fast_float, shared),
        else => unreachable,
        };

        // Expose the Nzsl artifact
        b.installArtifact(lib);

        //nzslzig.addSystemIncludePath(upstream.path("include"));

        nzslzig.linkLibrary(lib);
        docs.linkLibrary(lib);
    }

    // Examples
    const examples = [_]struct { []const u8, []const u8 }{
        .{ "mandelbrot", "examples/mandelbrot.zig" },
    };

    for (examples) |example| {
        const exe = b.addExecutable(.{
            .name = example[0],
            .root_source_file = .{ .path = example[1] },
            .target = target,
            .optimize = optimize,
        });
        exe.root_module.addImport("nzslzig", nzslzig);

        const artifact = b.addInstallArtifact(exe, .{});
        const exe_step = b.step(b.fmt("install-example-{s}", .{example[0]}), b.fmt("Install {s} example", .{example[0]}));
        exe_step.dependOn(&artifact.step);

        const run_cmd = b.addRunArtifact(exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| run_cmd.addArgs(args);

        const run_step = b.step(b.fmt("run-example-{s}", .{example[0]}), b.fmt("Run {s} example", .{example[0]}));
        run_step.dependOn(&run_cmd.step);
    }

    docs.root_module.addOptions("config", config);
    docs.root_module.addImport("nzslzig", nzslzig);

    const install_docs = b.addInstallDirectory(.{
        .source_dir = docs.getEmittedDocs(),
        .install_dir = .prefix,
        .install_subdir = "docs",
    });

    const docs_step = b.step("docs", "Build and install the documentation");
    docs_step.dependOn(&install_docs.step);
}

fn buildNzsl(b: *Build, target: Build.ResolvedTarget, optimize: std.builtin.OptimizeMode, upstream: *Build.Dependency, nazaraUtils: *Build.Dependency, frozen: *Build.Dependency, ordered_map: *Build.Dependency, fast_float: *Build.Dependency, fmt: *Build.Dependency, shared: bool) *Step.Compile {

    const lib_opts = .{
        .name = "nzsl",
        .target = target,
        .optimize = optimize,
    };
    const lib = if (shared)
    b.addSharedLibrary(lib_opts)
    else
    b.addStaticLibrary(lib_opts);

    lib.addSystemIncludePath(upstream.path("include"));
    lib.addSystemIncludePath(upstream.path("src"));

    lib.addSystemIncludePath(nazaraUtils.path("include"));
    lib.addSystemIncludePath(frozen.path("include"));
    lib.addSystemIncludePath(fmt.path("include"));
    lib.addSystemIncludePath(ordered_map.path("include"));
    lib.addSystemIncludePath(fast_float.path("include"));

    const flags = [_][]const u8{
        if (shared)
        "-DCNZSL_DYNAMIC" else "-DCNZSL_STATIC",
        if (shared) "-DNZSL_DYNAMIC" else "-DNZSL_STATIC",
        "-DCNZSL_BUILD",
        "-DNZSL_BUILD",
        "-DFMT_HEADER_ONLY",

        // Define target-specific macro
        //switch (target.result.os.tag) {
        //.linux => "-DLUA_USE_LINUX",
        //.macos => "-DLUA_USE_MACOSX",
        //.windows => "-DLUA_USE_WINDOWS",
        //else => "-DLUA_USE_POSIX",
        //},

        // Enable api check
        // if (optimize == .Debug) "-DLUA_USE_APICHECK" else "",
    };

    const nzsl_source_files = &nzsl_source_files_list;

    lib.addCSourceFiles(.{
        .root = .{ .dependency = .{
            .dependency = upstream,
            .sub_path = "",
        } },
        .files = nzsl_source_files,
        .flags = &flags,
    });

    lib.linkLibCpp();

    lib.installHeader(upstream.path("include/CNZSL/CNZSL.h"), "CNZSL/CNZSL.h");
    lib.installHeader(upstream.path("include/CNZSL/Config.h"), "CNZSL/Config.h");
    lib.installHeader(upstream.path("include/CNZSL/DebugLevel.h"), "CNZSL/DebugLevel.h");
    lib.installHeader(upstream.path("include/CNZSL/GlslWriter.h"), "CNZSL/GlslWriter.h");
    lib.installHeader(upstream.path("include/CNZSL/LangWriter.h"), "CNZSL/LangWriter.h");
    lib.installHeader(upstream.path("include/CNZSL/Module.h"), "CNZSL/Module.h");
    lib.installHeader(upstream.path("include/CNZSL/Parser.h"), "CNZSL/Parser.h");
    lib.installHeader(upstream.path("include/CNZSL/ShaderStageType.h"), "CNZSL/ShaderStageType.h");
    lib.installHeader(upstream.path("include/CNZSL/SpirvWriter.h"), "CNZSL/SpirvWriter.h");
    lib.installHeader(upstream.path("include/CNZSL/WriterStates.h"), "CNZSL/WriterStates.h");

    return lib;
}

const nzsl_source_files_list = [_][]const u8{
    "src/NZSL/Ast/AstSerializer.cpp",
    "src/NZSL/Ast/Cloner.cpp",
    "src/NZSL/Ast/ConstantPropagationVisitor.cpp",
    "src/NZSL/Ast/ConstantPropagationVisitor_BinaryArithmetics.cpp",
    "src/NZSL/Ast/ConstantPropagationVisitor_BinaryComparison.cpp",
    "src/NZSL/Ast/ConstantValue.cpp",
    "src/NZSL/Ast/DependencyCheckerVisitor.cpp",
    "src/NZSL/Ast/EliminateUnusedPassVisitor.cpp",
    "src/NZSL/Ast/ExportVisitor.cpp",
    "src/NZSL/Ast/ExpressionType.cpp",
    "src/NZSL/Ast/ExpressionVisitor.cpp",
    "src/NZSL/Ast/ExpressionVisitorExcept.cpp",
    "src/NZSL/Ast/IndexRemapperVisitor.cpp",
    "src/NZSL/Ast/Nodes.cpp",
    "src/NZSL/Ast/RecursiveVisitor.cpp",
    "src/NZSL/Ast/ReflectVisitor.cpp",
    "src/NZSL/Ast/SanitizeVisitor.cpp",
    "src/NZSL/Ast/StatementVisitor.cpp",
    "src/NZSL/Ast/StatementVisitorExcept.cpp",
    "src/NZSL/Ast/Utils.cpp",
    "src/NZSL/FilesystemModuleResolver.cpp",
    "src/NZSL/GlslWriter.cpp",
    "src/NZSL/Lang/Errors.cpp",
    "src/NZSL/LangWriter.cpp",
    "src/NZSL/Lexer.cpp",
    "src/NZSL/ModuleResolver.cpp",
    "src/NZSL/Parser.cpp",
    "src/NZSL/Serializer.cpp",
    "src/NZSL/ShaderWriter.cpp",
    "src/NZSL/SpirV/SpirvAstVisitor.cpp",
    "src/NZSL/SpirV/SpirvConstantCache.cpp",
    "src/NZSL/SpirV/SpirvData.cpp",
    "src/NZSL/SpirV/SpirvDecoder.cpp",
    "src/NZSL/SpirV/SpirvExpressionLoad.cpp",
    "src/NZSL/SpirV/SpirvExpressionStore.cpp",
    "src/NZSL/SpirV/SpirvPrinter.cpp",
    "src/NZSL/SpirV/SpirvSectionBase.cpp",
    "src/NZSL/SpirvWriter.cpp",
    "src/CNZSL/GlslWriter.cpp",
    "src/CNZSL/LangWriter.cpp",
    "src/CNZSL/Module.cpp",
    "src/CNZSL/Parser.cpp",
    "src/CNZSL/SpirvWriter.cpp",
    "src/CNZSL/WriterStates.cpp",
};