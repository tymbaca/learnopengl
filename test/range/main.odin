package range

import "core:fmt"
import "core:time"
import rl "vendor:raylib"

NAME :: "render"
WIDTH :: 800
HEIGHT :: 600

_camera: rl.Camera

init :: proc() {
	rl.InitWindow(WIDTH, HEIGHT, NAME)
	rl.SetTargetFPS(60)

	_camera.position = {0, 2, 4}
	_camera.up = {0, 1, 0}
	_camera.target = {0, 0, 1}
	_camera.fovy = 90
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

draw :: proc() {
	rl.BeginDrawing()
	rl.ClearBackground(rl.BLACK)

	rl.BeginMode3D(_camera)

	// shit here
    rl.DrawGrid(10, 10)

	rl.EndMode3D()

	rl.EndDrawing()
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

