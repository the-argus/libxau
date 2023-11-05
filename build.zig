const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const xproto_header_dir = b.option([]const u8, "xproto_header_dir", "Include directory to append, intended to contain X11/Xfuncproto.h") orelse block: {
        var envmap = std.process.getEnvMap(b.allocator) catch @panic("OOM");
        defer envmap.deinit();

        if (envmap.get("XPROTO_INCLUDE_DIR")) |dir| {
            break :block b.allocator.dupe(u8, dir) catch @panic("OOM");
        }

        break :block "xproto_header_fallback/";
    };

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();

    const lib = b.addStaticLibrary(.{
        .name = "Xau",
        .target = target,
        .optimize = optimize,
    });

    lib.addCSourceFiles(&.{
        "AuDispose.c",
        "AuFileName.c",
        "AuGetAddr.c",
        "AuGetBest.c",
        "AuLock.c",
        "AuRead.c",
        // "Autest.c",
        "AuUnlock.c",
        "AuWrite.c",
    }, b.allocator.dupe([]const u8, flags.items) catch @panic("OOM"));

    lib.addIncludePath(.{ .path = "include" });
    lib.addIncludePath(.{ .path = xproto_header_dir });

    lib.linkLibC();

    lib.installHeadersDirectory("include/X11", "X11");

    b.installArtifact(lib);
}
