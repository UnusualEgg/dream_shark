const w4 = @import("wasm4.zig");
const std = @import("std");

const ObstacleType = enum { square };
const Obstacle = struct {
    x: f32,
    t: ObstacleType,

    const y: i32 = 63;
    const size = 8;
    fn isColliding(self: *const Obstacle, other_x: f32, other_y: f32, other_width: f32, other_height: f32) bool {
        return (self.x <= other_x + other_width and self.x + size >= other_x) and (y <= other_y + other_height and y + size >= other_y);
    }
    fn update(self: *Obstacle, camera_offset: f32) void {
        self.x += camera_offset;
    }
    fn draw(self: *const Obstacle) void {
        w4.DRAW_COLORS.* = 0x42;
        w4.rect(@intFromFloat(self.x), y, size, size);
    }
};
pub const Obstacles = struct {
    list: [20]?Obstacle = @splat(null),

    fn spawnTypeAt(self: *Obstacles, t: ObstacleType, x: f32) void {
        const maybe_free_slot: ?*?Obstacle = for (&self.list) |*obs| {
            if (obs.* == null) {
                break obs;
            }
        } else null;

        if (maybe_free_slot) |obstacle| {
            w4.trace("spawned obstacle");
            obstacle.* = Obstacle{ .t = t, .x = x };
        } else {
            w4.trace("failed to spawn obstacle");
        }
    }
    pub fn spawnRandom(self: *Obstacles, rng: std.Random, camera_offset: f32) void {
        const max_off = 30.00;
        const obs_type = rng.enumValue(ObstacleType);
        const x = rng.float(f32) * max_off + camera_offset + w4.screen_sizef;
        self.spawnTypeAt(obs_type, x);
    }
    pub fn update(self: *Obstacles, camera_offset: f32) void {
        for (0..self.list.len) |i| {
            if (self.list[i]) |*obstacle| {
                obstacle.update(camera_offset);
            }
        }
    }
    pub fn draw(self: *const Obstacles) void {
        for (&self.list) |*slot| {
            if (slot.*) |obstacle| {
                obstacle.draw();
            }
        }
    }
};
