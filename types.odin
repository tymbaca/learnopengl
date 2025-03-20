package main

import "core:fmt"
import "core:strings"
import "core:math"
import "core:math/linalg"
import "core:slice"
import "shader"

dot :: linalg.dot
cross :: linalg.cross
cos :: math.cos
acos :: math.acos
sin :: math.sin
asin :: math.asin
DEG_PER_RAD :: linalg.DEG_PER_RAD
RAD_PER_DEG :: linalg.RAD_PER_DEG
normalize :: linalg.normalize

vec2 :: [2]f32
vec3 :: [3]f32
vec4 :: [4]f32
mat4 :: matrix[4, 4]f32
mat3 :: matrix[3, 3]f32

to_vec4 :: proc(vec: vec3) -> vec4 {
    return {vec.x, vec.y, vec.z, 1}
}

UP :: vec3{0,1,0}

Vertex_Attributes :: struct {
	pos: vec3,
    n:   vec3,
	uv:  vec2,
}

Camera :: struct {
    up:  vec3, // {0,1,0} for default
    pos: vec3,
    yaw, pitch: f32,
    // calculated
    look_at: Maybe(vec3),
    dir: vec3, // local for pos
}
//
// Model :: struct {
//     vertices: []Vertex_Attributes,
//     material: Material,
// }

// Material :: struct {
//     ambient: vec3,
//    
// }

Cube :: struct {
    pos: vec3,
    scale: vec3,
}

Light :: struct {
    ambient: vec3,
    diffuse: vec3,
    specular: vec3,
    show: bool,
    inner: union {
        DirectionalLight,
        PointLight,
        SpotLight,
    }
}

DirectionalLight :: struct {
    dir: vec3,
}

PointLight :: struct {
    pos: vec3,

    constant: f32,
    linear: f32,
    quadratic: f32,
}

SpotLight :: struct {
    pos: vec3,
    dir: vec3,

    angle: f32, // in degrees
}

shader_set_light :: proc(p: shader.Program, $name: cstring, light: Light) {
    shader.set(p, name+".ambient", light.ambient)
    shader.set(p, name+".diffuse", light.diffuse)
    shader.set(p, name+".specular", light.specular)

    switch l in light.inner {
    case DirectionalLight:
        shader.set(p, name+".tag", i32(1))
        shader.set(p, name+".direction", l.dir)
    case PointLight:
        shader.set(p, name+".tag", i32(2))
        shader.set(p, name+".position", l.pos)
        shader.set(p, name+".constant", l.constant)
        shader.set(p, name+".linear", l.linear)
        shader.set(p, name+".quadratic", l.quadratic)
    case SpotLight:
        shader.set(p, name+".tag", i32(3))
        return
    }
}
