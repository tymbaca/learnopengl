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
import "shader"

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

LIGHT_POS := vec3{4,4,4}
LIGHT_COLOR := vec3{0.6, 1, 0.1}
light_positions := []vec3{
    LIGHT_POS,
}

draw :: proc() {
	// Set the opengl clear color
	// 0-1 rgba values
    global_light := LIGHT_COLOR * 0.1
	gl.ClearColor(global_light.r, global_light.g, global_light.b, 1.0)
	// Clear the screen with the set clearcolor
	gl.Clear(gl.COLOR_BUFFER_BIT)


    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, TEXTURES[.wall].id)
    gl.ActiveTexture(gl.TEXTURE1)
    gl.BindTexture(gl.TEXTURE_2D, TEXTURES[.awesomeface].id)


    global_time := f32(time.duration_seconds(time.since(START)))
    // factor := math.sin(time.duration_seconds(time.since(START)))
    factor := 1

    w, h := glfw.GetWindowSize(WINDOW)
    projection := linalg.matrix4_perspective_f32(65*RAD_PER_DEG, f32(w)/f32(h), 0.1, 100)
    view := linalg.matrix4_look_at_f32(CAMERA.pos, (CAMERA.dir + CAMERA.pos), CAMERA.up)

    for pos in cube_positions {
        gl.BindVertexArray(CONTAINER_VAO)
        model := linalg.identity_matrix(mat4)
        model = linalg.matrix4_rotate_f32(global_time*RAD_PER_DEG*10, vec3{1,0,0}) * model
        model = linalg.matrix4_translate_f32(pos) * model


        shader.use(CUBE_SHADER)

        shader.set(CUBE_SHADER, "model", model)
        shader.set(CUBE_SHADER, "view", view)
        shader.set(CUBE_SHADER, "projection", projection)

        shader.set(CUBE_SHADER, "ourTexture1", TEXTURES[.wall].id)
        shader.set(CUBE_SHADER, "ourTexture2", i32(1))

        shader.set(CUBE_SHADER, "ambientLight", global_light)
        shader.set(CUBE_SHADER, "lightPos", LIGHT_POS)
        shader.set(CUBE_SHADER, "lightColor", LIGHT_COLOR)

        gl.DrawArrays(gl.TRIANGLES, 0, 36)
    }

    for pos in ([]vec3{LIGHT_POS}) {
        gl.BindVertexArray(LIGHT_VAO)
        model := linalg.identity(mat4)
        model = linalg.matrix4_scale_f32({0.4, 0.4, 0.4}) * model
        model = linalg.matrix4_translate_f32(pos) * model
        
        shader.use(LIGHT_SHADER)
        shader.set(LIGHT_SHADER, "model", model)
        shader.set(LIGHT_SHADER, "view", view)
        shader.set(LIGHT_SHADER, "projection", projection)

        shader.set(LIGHT_SHADER, "color", LIGHT_COLOR)

        gl.DrawArrays(gl.TRIANGLES, 0, 36)
    }
}
