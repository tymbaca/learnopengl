package main

import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"
import "base:runtime"
import rl "vendor:raylib"
import "core:math"
import "core:math/linalg"
import "core:time"
import "shader/program"
import "core:c"

SPEED :: 0.01

update :: proc() {
    mov: vec3
    if is_key_pressed(glfw.KEY_W) {
        mov.z -= SPEED
    }
    if is_key_pressed(glfw.KEY_S) {
        mov.z += SPEED
    }
    if is_key_pressed(glfw.KEY_D) {
        mov.x += SPEED
    }
    if is_key_pressed(glfw.KEY_A) {
        mov.x -= SPEED
    }
    if is_key_pressed(glfw.KEY_F) {
        mov.y += SPEED
    }
    if is_key_pressed(glfw.KEY_R) {
        mov.y -= SPEED
    }

    CAMERA.pos += mov

    look_at, ok := CAMERA.look_at.?
    if ok {
        CAMERA.dir = look_at - CAMERA.pos
    }
    // view := linalg.matrix4_look_at_f32(CAMERA.pos, CAMERA.pos + CAMERA.dir, CAMERA.up)
    // mov = (view * to_vec4(mov)).xyz
    // CAMERA.pos += mov
}

is_key_pressed :: proc(key: c.int) -> bool {
    state := glfw.GetKey(WINDOW, key)
    return state == glfw.PRESS || state == glfw.REPEAT
}
