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

    gl.BindVertexArray(VAO)
    model := linalg.identity_matrix(mat4)
    model = linalg.matrix4_rotate_f32(global_time*RAD_PER_DEG, vec3{1,0,0}) * model

    view := linalg.matrix4_translate_f32({0, 0, -3}) * linalg.identity_matrix(mat4)

    projection := linalg.matrix4_perspective_f32(45, WIDTH/HEIGHT, 0.1, 100)
    gl.DrawArrays(gl.TRIANGLES, 0, 36)

    program.set(PROGRAM, "model", model)
    program.set(PROGRAM, "view", view)
    program.set(PROGRAM, "projection", projection)

}
