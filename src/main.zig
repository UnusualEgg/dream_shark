const w4 = @import("wasm4.zig");
// const std = @import("std");
// const Shark = @import("Shark.zig");
// const Surfer = @import("Surfer.zig");
// const Water = @import("Water.zig");
// const Beam = @import("Beam.zig");
// const obs = @import("obstacles.zig");

const State = @import("State.zig");
var state: State = .{};

export fn start() void {
    w4.PALETTE.* = .{
        0x5995d1, //sky blue (light)
        0xffffff, //white
        0x1d456d, //water blue (dark)
        0x58dd58, //green
    };
}

export fn update() void {
    state.update();
    state.draw();
}
