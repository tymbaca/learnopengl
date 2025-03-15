package main

import "core:time"
import "core:fmt"
import "core:image"
import "core:image/png"
import "core:bytes"
import "core:testing"
import rl "vendor:raylib"
import "core:math/linalg"
import "core:math"

vec2 :: [2]f32
vec3 :: [3]f32
vec4 :: [4]f32
mat4 :: matrix[4,4]f32

dot :: linalg.dot
cross :: linalg.cross
cos :: linalg.cos
acos :: linalg.acos
DEG_PER_RAD :: linalg.DEG_PER_RAD
RAD_PER_DEG :: linalg.RAD_PER_DEG
normalize :: linalg.normalize

Vertex_Attributes :: struct {
    pos: vec3,
    uv: vec2,
}

// to_vertex_attributes :: #force_inline proc(arr: $T/[$N]f32) -> []Vertex_Attributes {
//     varr := transmute([N/5]Vertex_Attributes)arr
//     return varr[:]
// }

to_vertex_attributes :: proc(fs: []f32) -> []Vertex_Attributes {
    varr := cast([^]Vertex_Attributes)raw_data(fs)
    return varr[:len(fs)/5]
}

main :: proc() {
    {
        v1 := vec3{5, 0, 0}
        v2 := vec3{1, 0, 5}
        fmt.println(dot(normalize(v1), normalize(v2)))
    }
    // {
    //     linalg.matrix3_look_at_f32()
    // }

    // data := []f32{
    //     1, 2, 3, 4, 5,
    //     1, 2, 3, 4, 5,
    // }
    //
    // vas := to_vertex_attributes(data)
    //
    // for va in vas {
    //     fmt.println(va)
    // }
    // {
    //     v1 := vec2{1, 0}
    //     v2 := vec2{0, 1}
    //    
    //     fmt.println(v1 * v2)
    //     fmt.println(dot(v1, v2))
    //     fmt.println(dot(normalize(v1), normalize(v2)))
    //     fmt.println(acos(dot(normalize(v2), normalize(v1))) * DEG_PER_RAD)
    //     fmt.println(acos(dot(v2, v1)) * DEG_PER_RAD)
    // }

    {
        // mat := mat4{
        //     2, 0, 0, 3,
        //     0, 2, 0, 3,
        //     0, 0, 2, 3,
        //     0, 0, 0, 1,
        // }

        // vec := vec4{1, 0, 0, 1}
        // rot: f32 = 0
        // for {
        //     rot += 3*RAD_PER_DEG
        //     time.sleep(50 * time.Millisecond)
        //     // mat := linalg.matrix4_rotate(rot, [3]f32{0,0,1})
        //     // vec *= linalg.matrix4_scale_f32(vec3{2, 2, 2})
        //     vec = linalg.matrix4_translate(vec3{2, 2, 2}) * vec
        //
        //     fmt.println(vec)
        // }
    }

    // {
    //     // mat := mat4{
    //     //     1,  2,  3,  4,
    //     //     5,  6,  7,  8,
    //     //     9,  10, 11, 12,
    //     //     13, 14, 15, 16
    //     // }
    //     mat := linalg.identity(mat4)
    //
    //     mat = linalg.transpose(mat)
    //     ptr := ([^]f32)(&mat)
    //     for i in 0..<16 {
    //         fmt.println(ptr[i])
    //     }
    // }

    // {
    //     ortho := linalg.matrix_ortho3d_f32(0, 10, 0, 10, 0, 10)
    //     fmt.println(ortho * vec4{2, 5, 4, 1})
    // }
    //
    // {
    //     persp := linalg.matrix4_perspective_f32(45, 600/400, 0.1, 100)
    //     fmt.println(persp * vec4{0, 10, 1, 1})
    //     fmt.println(persp * vec4{0, 10, 5, 1})
    //     fmt.println(persp * vec4{0, 10, 10, 1})
    //     fmt.println(persp * vec4{0, 10, 20, 1})
    //     fmt.println(persp * vec4{0, 10, 50, 1})
    // }
    // log(len("hello") == 5)
    // log(len(val) == 5)
}

// NOTE: scale -> rotate -> translate

/*
len(%s) == 5  // val
len("hello") == 5 
*/

log :: proc(cond: bool, msg := #caller_expression(cond))  {
    fmt.println(msg)
}

@(test)
main_test :: proc(t: ^testing.T) {
    
    // {
    //     paths := make([]string, 3)
    //     paths = []string{"resources/wall.png", "resources/container.png", "resources/awesomeface.png"}
    //     for path, i in paths {
    //         fmt.println(path)
    //     }
    // }
    //
    // {
    //     wall := "resources/wall.png"
    //     container := "resources/container.png"
    //     awesomeface := "resources/awesomeface.png"
    //     paths := []string{wall, container, awesomeface}
    //     for path, i in paths {
    //         fmt.println(path)
    //     }
    // }

    // {
    //     for path, i in []string{"resources/wall.png", "resources/container.png", "resources/awesomeface.png"} {
    //         fmt.println(path)
    //     }
    // }
}
