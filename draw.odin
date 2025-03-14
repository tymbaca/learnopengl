package main

import "core:fmt"
import "core:c"
import gl "vendor:OpenGL"
import "vendor:glfw"
import "base:runtime"
import rl "vendor:raylib"
import "core:math"
import "core:math/linalg"
import "core:time"
import "shader/program"

cube_positions := []vec3{
    {0,0,0},
    // {2,0,0},
    // {2,1,0},
    // {-4,1,0},
    // {-4,-3,0},

    {2,0,0},
    {0,2,0},
    {0,0,4},
}

draw :: proc() {
	// Set the opengl clear color
	// 0-1 rgba values
	gl.ClearColor(0.2, 0.3, 0.3, 1.0)
	// Clear the screen with the set clearcolor
	gl.Clear(gl.COLOR_BUFFER_BIT)


    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, TEXTURES[.wall].id)
    gl.ActiveTexture(gl.TEXTURE1)
    gl.BindTexture(gl.TEXTURE_2D, TEXTURES[.awesomeface].id)

    program.use(PROGRAM)

    global_time := 30*f32(time.duration_seconds(time.since(START)))
    // factor := math.sin(time.duration_seconds(time.since(START)))
    factor := 1

    for pos in cube_positions {
        gl.BindVertexArray(VAO)
        model := linalg.identity_matrix(mat4)
        model = linalg.matrix4_rotate_f32(global_time*RAD_PER_DEG, vec3{1,0,0}) * model
        model = linalg.matrix4_translate_f32(pos) * model

        // view := linalg.identity_matrix(mat4)
        view := linalg.matrix4_look_at_f32(CAMERA.pos, (CAMERA.dir - CAMERA.pos), -CAMERA.up)
        // view = linalg.matrix4_rotate_f32(global_time * math.RAD_PER_DEG, {0, 1, 0}) * view
        // view = linalg.matrix4_translate_f32(CAMERA.pos * {1, 1, -1}) * view

        w, h := glfw.GetWindowSize(WINDOW)
        projection := linalg.matrix4_perspective_f32(55, f32(w)/f32(h), 0.1, 100)

        program.set(PROGRAM, "model", model)
        program.set(PROGRAM, "view", view)
        program.set(PROGRAM, "projection", projection)

        gl.DrawArrays(gl.TRIANGLES, 0, 36)
    }
}
