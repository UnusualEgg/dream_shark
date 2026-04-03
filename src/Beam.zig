const Beam = @This();
const w4 = @import("wasm4.zig");
const Shark = @import("Shark.zig");
const Surfer = @import("Surfer.zig");

size: i32 = 0,

const width: i32 = 50;

pub fn update(self: *Beam, gamepad: u8, shark_x: i32, shark_alive: *bool) void {
    //shrink over time
    self.size -= 2;
    if (self.size < 0) {
        self.size = 0;
    }
    if (gamepad & w4.BUTTON_1 != 0 and self.size == 0 and shark_alive.*) {
        self.size = width;
        const hitbox_inset = 10;
        const shark_right = (shark_x + Shark.width) - hitbox_inset;
        const shark_left = shark_x + hitbox_inset;
        const screen_middle = w4.screen_size / 2;
        const beam_half = (width / 2);
        const beam_left = screen_middle - beam_half;
        const beam_right = screen_middle + beam_half;
        if (shark_right >= beam_left and shark_left <= beam_right) {
            shark_alive.* = false;
        }
    }
}
pub fn draw(self: *const Beam) void {
    if (self.size > 0) {
        w4.DRAW_COLORS.* = 0x0002;
        w4.rect(Surfer.x - @divFloor(self.size, 2), 0, @intCast(self.size), w4.screen_size);
    }
}
