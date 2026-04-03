const State = @This();
const w4 = @import("wasm4.zig");
const Shark = @import("Shark.zig");
const Surfer = @import("Surfer.zig");
const Beam = @import("Beam.zig");
const std = @import("std");
const obs = @import("obstacles.zig");
const Water = @import("Water.zig");

const PRNG = std.Random.DefaultPrng;

surfer: Surfer = .{},
beam: Beam = .{},
shark: Shark = .{},
water: Water = .{},
prev_button2_state: bool = false,
moved: bool = false,
prng: PRNG = .init(0),
obstacles: obs.Obstacles = .{},
ticks: u64 = 0,
distance: f32 = 0,

pub fn update(self: *State) void {
    const gamepad = w4.GAMEPAD1.*;

    //reset button
    const curr_button2_state = gamepad & w4.BUTTON_2 != 0;
    if (curr_button2_state and !self.prev_button2_state and self.beam.size == 0) {
        self.shark.alive = true;
        self.surfer.speed = 0;
        self.shark.x = w4.screen_sizef;
    }
    self.prev_button2_state = gamepad & w4.BUTTON_2 != 0;

    //update
    const camera_offset: f32 = if (self.shark.alive) (-self.surfer.speed) else 0;
    self.distance -= camera_offset;
    self.beam.update(gamepad, @intFromFloat(self.shark.x), &self.shark.alive);
    if (self.shark.alive) {
        self.surfer.update(gamepad);
        self.shark.update(camera_offset);
        self.water.update(camera_offset);
        self.obstacles.update(camera_offset);
    }
    if (!self.moved and gamepad & w4.BUTTON_RIGHT != 0)
        self.surfer.startMoving();
    if (gamepad & (w4.BUTTON_LEFT | w4.BUTTON_RIGHT | w4.BUTTON_1) != 0) {
        self.moved = true;
        self.prng.seed(self.ticks);
    }
    if (self.moved and self.ticks % (60 * 20) == 0) {
        self.surfer.speedUp();
    }
    //DEBUG
    if (gamepad & w4.BUTTON_DOWN != 0) {
        self.obstacles.spawnRandom(self.prng.random(), camera_offset);
    }
    self.ticks +%= 1;
}
fn drawScore(self: *const State) void {
    var buf: [64]u8 = undefined;
    const str = std.fmt.bufPrint(&buf, "{:.0}", .{self.distance / 10}) catch "SCORE TOO BIG";
    const x = (w4.screen_size / 2) - (@as(i32, @intCast(str.len)) * 8);
    w4.DRAW_COLORS.* = 0x02;
    w4.text(str, x, 0);
}
pub fn draw(self: *const State) void {
    if (!self.moved) {
        w4.DRAW_COLORS.* = 2;
        const title: []const u8 = "My dream game :3";
        w4.text(title, (w4.screen_size / 2) - ((title.len / 2) * w4.FONT_SIZE), 10);
    }

    self.water.draw();
    self.obstacles.draw();
    self.surfer.draw();
    self.shark.draw();
    self.beam.draw();
    self.drawScore();
}
