package range

import "core:fmt"
import "core:time"
import rl "vendor:raylib"
import "core:math/linalg"

NAME :: "render"
WIDTH :: 1200
HEIGHT :: 800

_camera: rl.Camera

vec2 :: [2]f32
vec3 :: [3]f32
vec4 :: [4]f32
mat4 :: matrix[4, 4]f32

init :: proc() {
	rl.InitWindow(WIDTH, HEIGHT, NAME)
	rl.SetTargetFPS(60)

	_camera.position = {0, 2, 4}
	_camera.up = {0, 1, 0}
	_camera.target = {0, 0, 1}
	_camera.fovy = 60
	_camera.projection = .PERSPECTIVE
	rl.DisableCursor()
}

main :: proc() {
	init()

	for !rl.WindowShouldClose() {
		update()
		draw()
	}
}

transparent :: proc(color: rl.Color, factor: f32) -> rl.Color {
    color := color
    color.a = u8(f32(color.a) * factor)
    return color
}

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginMode3D(_camera)

	// shit here
    // rl.DrawGrid(20, 1)
    rl.DrawLine3D({-10, 0, 0}, {10, 0, 0}, transparent(rl.RED, 0.5))
    rl.DrawLine3D({0, -10, 0}, {0, 10, 0}, transparent(rl.GREEN, 0.5))
    rl.DrawLine3D({0, 0, -10}, {0, 0, 10}, transparent(rl.BLUE, 0.5))

    rl.DrawSphere({10, 0, 0}, 0.1, rl.RED)
    rl.DrawSphere({0, 10, 0}, 0.1, rl.GREEN)
    rl.DrawSphere({0, 0, 10}, 0.1, rl.BLUE)

    // CODE HERE
    {
        dir := vec3{2, 3, 4}
        pos := vec3{2, 3, 3}
        draw_vec_from(pos, pos+dir)
        // linalg.matrix4_look_at_f32()
    }


	rl.EndMode3D()

	rl.EndDrawing()
}

PROJ :: true

draw_vec :: proc(vec: vec3, color := rl.WHITE) {
    draw_vec_from({0,0,0}, vec, color)
}

draw_vec_from :: proc(from, to: vec3, color := rl.WHITE) {
    rl.DrawLine3D(from, to, color)
    rl.DrawSphere(to, 0.1, color)

    when PROJ {
        proj_color := color
        proj_color.a /= 2
        rl.DrawLine3D({0,0,0}, to * {1,0,1}, proj_color)
        rl.DrawLine3D(to, to * {1,0,1}, proj_color)

        if from != {0,0,0} {
            rl.DrawLine3D({0,0,0}, from * {1,0,1}, proj_color)
            rl.DrawLine3D(from, from * {1,0,1}, proj_color)
        }
    }
}

SPEED :: .2
MOUSE_SENSITIVITY :: .1
MOVE_SPEED :: .5

update :: proc() {
	//--------------------------------------------------------------------------------------------------

	rl.UpdateCameraPro(&_camera, get_movement(), get_rotation(), 0)


	/*
	wp := rl.GetWindowPosition()
	debug(wp)
	if rl.IsKeyDown(.LEFT) {
		wp.x -= 10
	}
	if rl.IsKeyDown(.RIGHT) {
		wp.x += 10
	}
	if rl.IsKeyDown(.UP) {
		wp.y -= 10
	}
	if rl.IsKeyDown(.DOWN) {
		wp.y += 10
	}
	rl.SetWindowPosition(i32(wp.x), i32(wp.y))
    */
}

get_movement :: proc() -> rl.Vector3 {
	forward := pressed_f32(.W) * SPEED
	backward := pressed_f32(.S) * SPEED
	x := forward - backward

	right := pressed_f32(.D) * SPEED
	left := pressed_f32(.A) * SPEED
	y := right - left

	up := pressed_f32(.R) * SPEED
	down := pressed_f32(.F) * SPEED
	z := up - down

	return {x, y, z}
}

get_rotation :: proc() -> rl.Vector3 {
	rot := rl.GetMouseDelta() * MOUSE_SENSITIVITY

	return {rot.x, rot.y, 0}
}

pressed_f32 :: proc(key: rl.KeyboardKey) -> f32 {
	return f32(int(rl.IsKeyDown(key)))
}

