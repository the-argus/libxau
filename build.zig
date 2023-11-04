const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    var flags = std.ArrayList([]const u8).init(b.allocator);
    defer flags.deinit();

    const lib = b.addStaticLibrary(.{
        .name = "xcb",
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
        "Autest.c",
        "AuUnlock.c",
        "AuWrite.c",
    }, b.allocator.dupe([]const u8, flags.items) catch @panic("OOM"));

    lib.addIncludePath(.{ .path = "include" });

    lib.linkLibC();

    lib.installHeadersDirectory("include/X11", "X11");

    b.installArtifact(lib);
}
