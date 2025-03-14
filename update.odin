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

SPEED :: 0.1

update :: proc() {
    update_camera(&CAMERA)
}


update_camera :: proc(c: ^Camera) {
    // c.dir = normalize(c.dir)

    mov: vec3
    if is_key_down(glfw.KEY_W) {
        mov += c.dir * SPEED
    }
    if is_key_down(glfw.KEY_S) {
        mov -= c.dir * SPEED
    }
    if is_key_down(glfw.KEY_D) {
        mov += normalize(cross(c.dir, UP)) * SPEED
    }
    if is_key_down(glfw.KEY_A) {
        mov -= normalize(cross(c.dir, UP)) * SPEED
    }
    if is_key_down(glfw.KEY_R) {
        mov += UP * SPEED
    }
    if is_key_down(glfw.KEY_F) {
        mov -= UP * SPEED
    }

    c.pos += mov

    look_at, ok := c.look_at.?
    if ok {
        c.dir = linalg.normalize(look_at - CAMERA.pos)
    }
    // view := linalg.matrix4_look_at_f32(CAMERA.pos, CAMERA.pos + CAMERA.dir, CAMERA.up)
    // mov = (view * to_vec4(mov)).xyz
    // CAMERA.pos += mov
}

is_key_down :: proc(key: c.int) -> bool {
    state := glfw.GetKey(WINDOW, key)
    return state == glfw.PRESS || state == glfw.REPEAT
}
