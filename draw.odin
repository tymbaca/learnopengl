package main

import im "lib/imgui"
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

cubes := []Cube{
    {pos = {0,-3,0}, scale = {20, 1, 20}},

    {pos = {0,0,0}, scale = {1,1,1}},
    {pos = {2,0,0}, scale = {1,1,1}},
    {pos = {0,2,0}, scale = {1,1,1}},
    {pos = {0,0,4}, scale = {1,1,1}},
}


LIGHT := Light {
    ambient  = {0.1, 0.1, 0.1},
    diffuse  = {1, 1, 1},
    specular = {1, 1, 1},
    show = true,
    inner = PointLight {
        pos = {4, 4, 4},
    }
}

lights := []Light{
    LIGHT,
    LIGHT,
}

SHININESS: f32 = 64
USE_SPEC: bool = true

draw :: proc() {
	// Set the opengl clear color
	// 0-1 rgba values
	gl.ClearColor(LIGHT.ambient.r, LIGHT.ambient.g, LIGHT.ambient.b, 1.0)
	// Clear the screen with the set clearcolor
	gl.Clear(gl.COLOR_BUFFER_BIT)

    gl.ActiveTexture(gl.TEXTURE0)
    gl.BindTexture(gl.TEXTURE_2D, TEXTURES[.metall_container_spec].id)
    gl.ActiveTexture(gl.TEXTURE1)
    gl.BindTexture(gl.TEXTURE_2D, TEXTURES[.metall_container].id)

    global_time := f32(time.duration_seconds(time.since(START)))
    // factor := math.sin(time.duration_seconds(time.since(START)))
    factor := 1

    w, h := glfw.GetWindowSize(WINDOW)
    projection := linalg.matrix4_perspective_f32(65*RAD_PER_DEG, f32(w)/f32(h), 0.1, 100)
    view := linalg.matrix4_look_at_f32(CAMERA.pos, (CAMERA.dir + CAMERA.pos), CAMERA.up)

    for cube in cubes {
        gl.BindVertexArray(CONTAINER_VAO)
        model := linalg.identity_matrix(mat4)
        model = linalg.matrix4_scale_f32(cube.scale) * model
        // model = linalg.matrix4_rotate_f32(global_time*RAD_PER_DEG*10, vec3{1,0,0}) * model
        model = linalg.matrix4_translate_f32(cube.pos) * model


        shader.use(CUBE_SHADER)

        shader.set(CUBE_SHADER, "modelMat", model)
        shader.set(CUBE_SHADER, "normalMat", mat3(linalg.transpose(linalg.inverse(model))))
        shader.set(CUBE_SHADER, "viewMat", view)
        shader.set(CUBE_SHADER, "projectionMat", projection)

        shader_set_light(CUBE_SHADER, "light", lights[0])
        // shader.set(CUBE_SHADER, "light.position", LIGHT_POS)
        // shader.set(CUBE_SHADER, "light.ambient", LIGHT.ambient)
        // shader.set(CUBE_SHADER, "light.diffuse", LIGHT.diffuse)
        // shader.set(CUBE_SHADER, "light.specular", LIGHT.specular)

        shader.set(CUBE_SHADER, "viewPos", CAMERA.pos)

        shader.set(CUBE_SHADER, "material.diffuse", i32(1))
        shader.set(CUBE_SHADER, "material.specular", i32(0))
        shader.set(CUBE_SHADER, "material.shininess", SHININESS)
        shader.set(CUBE_SHADER, "useSpec", USE_SPEC)


        gl.DrawArrays(gl.TRIANGLES, 0, 36)
    }

    for light in lights {
        if !light.show do continue

        gl.BindVertexArray(LIGHT_VAO)
        model := linalg.identity(mat4)
        model = linalg.matrix4_scale_f32({0.4, 0.4, 0.4}) * model
        model = linalg.matrix4_translate_f32(light.inner.(PointLight).pos) * model
        
        shader.use(LIGHT_SHADER)
        shader.set(LIGHT_SHADER, "modelMat", model)
        shader.set(LIGHT_SHADER, "viewMat", view)
        shader.set(LIGHT_SHADER, "projectionMat", projection)

        shader.set(LIGHT_SHADER, "color", light.diffuse)

        gl.DrawArrays(gl.TRIANGLES, 0, 36)
    }

    if im.Begin("Window containing a quit button") {
        if im.Button("The quit button in question") {
            glfw.SetWindowShouldClose(WINDOW, true)
        }
    }
    im.End()
}
