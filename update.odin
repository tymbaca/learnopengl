package main

import im "lib/imgui"
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
    update_stuff()
    update_camera(&CAMERA, delta)
    update_light()
}

update_stuff :: proc() {
    context.allocator = context.temp_allocator
    defer free_all()

    {
        im.Begin("stuff")
        defer im.End()
        im.SliderFloat("shininess", &SHININESS, 0, 256)
        im.Checkbox("use_spec", &USE_SPEC)
    }

    {
        im.Begin("lights")
        defer im.End()

        for &light, i in lights {
            if im.CollapsingHeader(fmt.caprint(i+1)) {
                im.ColorEdit3("light ambient", &light.ambient, {.HDR, .Float})
                im.ColorEdit3("light diffuse", &light.diffuse, {.HDR, .Float})
                im.ColorEdit3("light specular", &light.specular, {.HDR, .Float})

                #partial switch &l in light.inner {
                case DirectionalLight:
                    im.SliderFloat3("light dir", &l.dir, -1, 1)
                case PointLight:
                    im.SliderFloat3("light pos", &l.pos, -10, 10)
                case SpotLight:
                    im.SliderFloat3("light dir", &l.dir, -1, 1)
                    im.SliderFloat3("light pos", &l.pos, -10, 10)
                    im.SliderFloat("light angle", &l.angle, 0, 180)
                    im.SliderFloat("light cutoff", &l.cutoff, 0, 180)
                }
            }
        }
    }
}

update_light :: proc() {
    #partial switch &l in lights[0].inner {
    case SpotLight:
        l.pos = CAMERA.pos
        l.dir = CAMERA.dir
    case PointLight:
        l.pos = CAMERA.pos
    }
}

cursor := false
mouse_first_pos := true
last_mouse_pos: vec2
delta_mouse: vec2

update_camera :: proc(cam: ^Camera, delta: f32) {
    cam.dir = normalize(cam.dir)

    new_mouse_pos := get_mouse_pos()
    if !mouse_first_pos {
        delta_mouse = new_mouse_pos - last_mouse_pos
    } else {
        mouse_first_pos = false
    }
    last_mouse_pos = new_mouse_pos

    if is_key_down(glfw.KEY_Q) {
        cursor = false
    }
    if is_key_down(glfw.KEY_E) {
        cursor = true
    }
    glfw.SetInputMode(WINDOW, glfw.CURSOR, glfw.CURSOR_NORMAL if cursor else glfw.CURSOR_DISABLED)
    
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


    if !cursor {
        cam.yaw += delta_mouse.x * MOUSE_SENSITIVITY
        cam.pitch -= delta_mouse.y * MOUSE_SENSITIVITY
        if cam.pitch > 89 {cam.pitch = 89}
        if cam.pitch < -89 {cam.pitch = -89}
    }

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

is_key_released :: proc(key: c.int) -> bool {
    state := glfw.GetKey(WINDOW, key)
    return state == glfw.RELEASE
}

get_mouse_pos :: proc() -> vec2 {
    x, y := glfw.GetCursorPos(WINDOW)
    return {f32(x), f32(y)}
}
