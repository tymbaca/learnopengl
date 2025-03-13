package main

import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"
import "base:runtime"
import rl "vendor:raylib"
import "core:math"
import "core:time"
import "shader/program"
import "core:c"

SPEED :: 0.01

update :: proc() {
    if is_key_pressed(glfw.KEY_W) {
        CAMERA.pos.z -= SPEED
    }
    if is_key_pressed(glfw.KEY_S) {
        CAMERA.pos.z += SPEED
    }
    if is_key_pressed(glfw.KEY_A) {
        CAMERA.pos.x -= SPEED
    }
    if is_key_pressed(glfw.KEY_D) {
        CAMERA.pos.x += SPEED
    }
    if is_key_pressed(glfw.KEY_F) {
        CAMERA.pos.y -= SPEED
    }
    if is_key_pressed(glfw.KEY_R) {
        CAMERA.pos.y += SPEED
    }
}

is_key_pressed :: proc(key: c.int) -> bool {
    state := glfw.GetKey(WINDOW, key)
    return state == glfw.PRESS || state == glfw.REPEAT
}
