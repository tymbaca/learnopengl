package main

import "core:fmt"
import gl "vendor:OpenGL"
import "vendor:glfw"
import "base:runtime"
import rl "vendor:raylib"
import "core:math"
import "core:math/linalg"
import "core:time"
import "shader"
import "core:c"

SPEED :: 0.01
ROT_SPEED :: 0.002
MOUSE_SENSITIVITY :: 0.3

update :: proc(delta: f32) {
    update_camera(&CAMERA, delta)
    update_light()
}

update_light :: proc() {
    if is_key_down(glfw.KEY_U) {
        LIGHT_COLOR.r += 0.1
    }
    if is_key_down(glfw.KEY_J) {
        LIGHT_COLOR.r -= 0.1
    }
    if is_key_down(glfw.KEY_I) {
        LIGHT_COLOR.g += 0.1
    }
    if is_key_down(glfw.KEY_K) {
        LIGHT_COLOR.g -= 0.1
    }
    if is_key_down(glfw.KEY_O) {
        LIGHT_COLOR.b += 0.1
    }
    if is_key_down(glfw.KEY_L) {
        LIGHT_COLOR.b -= 0.1
    }
    LIGHT_COLOR = linalg.clamp(LIGHT_COLOR, 0, 10)

    mov: vec3
    if is_key_down(glfw.KEY_RIGHT) {
        mov.x += 1
    }
    if is_key_down(glfw.KEY_LEFT) {
        mov.x -= 1 
    }
    if is_key_down(glfw.KEY_UP) {
        mov.z -= 1 
    }
    if is_key_down(glfw.KEY_DOWN) {
        mov.z += 1 
    }
    LIGHT_POS += mov * SPEED * 5
}

update_camera :: proc(cam: ^Camera, delta: f32) {
    cam.dir = normalize(cam.dir)

    mov: vec3
    if is_key_down(glfw.KEY_W) {
        mov += cam.dir
    }
    if is_key_down(glfw.KEY_S) {
        mov -= cam.dir
    }
    if is_key_down(glfw.KEY_D) {
        mov += normalize(cross(cam.dir, UP))
    }
    if is_key_down(glfw.KEY_A) {
        mov -= normalize(cross(cam.dir, UP))
    }
    if is_key_down(glfw.KEY_R) {
        mov += UP
    }
    if is_key_down(glfw.KEY_F) {
        mov -= UP
    }


    cam.yaw += MOUSE_DELTA.x * MOUSE_SENSITIVITY
    cam.pitch -= MOUSE_DELTA.y * MOUSE_SENSITIVITY
    if cam.pitch > 89 {cam.pitch = 89}
    if cam.pitch < -89 {cam.pitch = -89}
    // fmt.println(cam.pitch, cam.yaw)

    cam.pos += mov * SPEED * delta

    look_at, ok := cam.look_at.?
    if ok {
        cam.dir = linalg.normalize(look_at - CAMERA.pos)
        return
    }

    cam.dir.x = cos(cam.yaw * RAD_PER_DEG) * cos(cam.pitch * RAD_PER_DEG)
    cam.dir.y = sin(cam.pitch * RAD_PER_DEG)
    cam.dir.z = sin(cam.yaw * RAD_PER_DEG) * cos(cam.pitch * RAD_PER_DEG)
    // view := linalg.matrix4_look_at_f32(CAMERA.pos, CAMERA.pos + CAMERA.dir, CAMERA.up)
    // mov = (view * to_vec4(mov)).xyz
    // CAMERA.pos += mov
}

is_key_down :: proc(key: c.int) -> bool {
    state := glfw.GetKey(WINDOW, key)
    return state == glfw.PRESS || state == glfw.REPEAT
}
