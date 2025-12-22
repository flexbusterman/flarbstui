const std = @import("std");

const min_zig_string = "0.11.0";

pub fn build(b: *std.Build) !void {
    // Check minimum Zig version
    const min_zig = std.SemanticVersion.parse(min_zig_string) catch unreachable;
    const current_zig = @import("builtin").zig_version;
    
    if (current_zig.order(min_zig) == .lt) {
        std.debug.print("Zig version {s} or higher is required, but found {}\n", .{ min_zig_string, current_zig });
        return error.ZigVersionTooOld;
    }

    // Standard target and optimize options
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // This is a bash script project, so we just create a no-op install step
    // The actual installation is handled by the bash scripts
    const install_step = b.getInstallStep();
    install_step.dependOn(&b.addInstallFile(
        .{ .path = "flarbstuibash" },
        "bin/flarbstui"
    ).step);
    
    install_step.dependOn(&b.addInstallFile(
        .{ .path = "installpackages" },
        "bin/installpackages"
    ).step);
    
    install_step.dependOn(&b.addInstallFile(
        .{ .path = "packages.json" },
        "share/flarbstui/packages.json"
    ).step);

    // Create a run step for the TUI (for convenience)
    const run_cmd = b.addSystemCommand(&[_][]const u8{"bash", "flarbstuibash"});
    run_cmd.step.dependOn(b.getInstallStep());

    const run_step = b.step("run", "Run the flarbstui TUI");
    run_step.dependOn(&run_cmd.step);

    _ = target;
    _ = optimize;
}
