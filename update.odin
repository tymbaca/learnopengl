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
ROT_SPEED :: 0.002

update :: proc(delta: f32) {
    update_camera(&CAMERA, delta)
}


update_camera :: proc(c: ^Camera, delta: f32) {
    c.dir = normalize(c.dir)

    mov: vec3
    if is_key_down(glfw.KEY_W) {
        mov += c.dir
    }
    if is_key_down(glfw.KEY_S) {
        mov -= c.dir
    }
    if is_key_down(glfw.KEY_D) {
        mov += normalize(cross(c.dir, UP))
    }
    if is_key_down(glfw.KEY_A) {
        mov -= normalize(cross(c.dir, UP))
    }
    if is_key_down(glfw.KEY_R) {
        mov += UP
    }
    if is_key_down(glfw.KEY_F) {
        mov -= UP
    }

    yaw: f32
    pitch: f32
    if is_key_down(glfw.KEY_LEFT) {
        yaw -= 1
    }
    if is_key_down(glfw.KEY_RIGHT) {
        yaw += 1
    }
    if is_key_down(glfw.KEY_UP) {
        pitch += 1
    }
    if is_key_down(glfw.KEY_DOWN) {
        pitch -= 1
    }
    c.yaw += yaw * ROT_SPEED * delta
    c.pitch += pitch * ROT_SPEED * delta

    c.pos += mov * SPEED * delta

    look_at, ok := c.look_at.?
    if ok {
        c.dir = linalg.normalize(look_at - CAMERA.pos)
        return
    }

    c.dir.x = cos(c.yaw) * cos(c.pitch)
    c.dir.y = sin(c.pitch)
    c.dir.z = sin(c.yaw) * cos(c.pitch)
    // view := linalg.matrix4_look_at_f32(CAMERA.pos, CAMERA.pos + CAMERA.dir, CAMERA.up)
    // mov = (view * to_vec4(mov)).xyz
    // CAMERA.pos += mov
}

is_key_down :: proc(key: c.int) -> bool {
    state := glfw.GetKey(WINDOW, key)
    return state == glfw.PRESS || state == glfw.REPEAT
}
