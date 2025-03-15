package main

import "core:math"
import "core:math/linalg"
import "core:slice"

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
