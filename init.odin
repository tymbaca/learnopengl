package main

import "core:slice"
import "base:runtime"
import "core:c"
import "core:fmt"
import "core:image"
import "core:image/png"
import "core:math"
import "core:time"
import "shader"
import gl "vendor:OpenGL"
import "vendor:glfw"
import rl "vendor:raylib"

init :: proc() -> (ok: bool) {
	fmt.println("OpenGL Version: ", gl.GetString(gl.VERSION))
	fmt.println("GLSL Version: ", gl.GetString(gl.SHADING_LANGUAGE_VERSION))

    TEXTURES[.wall]        = shader.load_texture("resources/wall.png") or_return
    TEXTURES[.container]   = shader.load_texture("resources/container.png") or_return
    TEXTURES[.awesomeface] = shader.load_texture("resources/awesomeface.png") or_return
    TEXTURES[.metall_container] = shader.load_texture("resources/container2.png") or_return
    TEXTURES[.metall_container_spec] = shader.load_texture("resources/container2_specular.png") or_return

	CUBE_SHADER = shader.new("resources/shader/cube.vs", "resources/shader/cube.fs") or_return
	LIGHT_SHADER = shader.new("resources/shader/light.vs", "resources/shader/light.fs") or_return

	// Own drawing code here
	vs := slice.reinterpret([]Vertex_Attributes, []f32{
    -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  0.0, 0.0,
     0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  1.0, 0.0, 
     0.5,  0.5, -0.5,  0.0,  0.0, -1.0,  1.0, 1.0, 
     0.5,  0.5, -0.5,  0.0,  0.0, -1.0,  1.0, 1.0, 
    -0.5,  0.5, -0.5,  0.0,  0.0, -1.0,  0.0, 1.0, 
    -0.5, -0.5, -0.5,  0.0,  0.0, -1.0,  0.0, 0.0, 
                                                  
    -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,   0.0, 0.0,
     0.5, -0.5,  0.5,  0.0,  0.0, 1.0,   1.0, 0.0,
     0.5,  0.5,  0.5,  0.0,  0.0, 1.0,   1.0, 1.0,
     0.5,  0.5,  0.5,  0.0,  0.0, 1.0,   1.0, 1.0,
    -0.5,  0.5,  0.5,  0.0,  0.0, 1.0,   0.0, 1.0,
    -0.5, -0.5,  0.5,  0.0,  0.0, 1.0,   0.0, 0.0,
                                                  
    -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,  1.0, 0.0,
    -0.5,  0.5, -0.5, -1.0,  0.0,  0.0,  1.0, 1.0,
    -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,  0.0, 1.0,
    -0.5, -0.5, -0.5, -1.0,  0.0,  0.0,  0.0, 1.0,
    -0.5, -0.5,  0.5, -1.0,  0.0,  0.0,  0.0, 0.0,
    -0.5,  0.5,  0.5, -1.0,  0.0,  0.0,  1.0, 0.0,
                                                  
     0.5,  0.5,  0.5,  1.0,  0.0,  0.0,  1.0, 0.0,
     0.5,  0.5, -0.5,  1.0,  0.0,  0.0,  1.0, 1.0,
     0.5, -0.5, -0.5,  1.0,  0.0,  0.0,  0.0, 1.0,
     0.5, -0.5, -0.5,  1.0,  0.0,  0.0,  0.0, 1.0,
     0.5, -0.5,  0.5,  1.0,  0.0,  0.0,  0.0, 0.0,
     0.5,  0.5,  0.5,  1.0,  0.0,  0.0,  1.0, 0.0,
                                                  
    -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,  0.0, 1.0,
     0.5, -0.5, -0.5,  0.0, -1.0,  0.0,  1.0, 1.0,
     0.5, -0.5,  0.5,  0.0, -1.0,  0.0,  1.0, 0.0,
     0.5, -0.5,  0.5,  0.0, -1.0,  0.0,  1.0, 0.0,
    -0.5, -0.5,  0.5,  0.0, -1.0,  0.0,  0.0, 0.0,
    -0.5, -0.5, -0.5,  0.0, -1.0,  0.0,  0.0, 1.0,
                                                  
    -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,  0.0, 1.0,
     0.5,  0.5, -0.5,  0.0,  1.0,  0.0,  1.0, 1.0,
     0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  1.0, 0.0,
     0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  1.0, 0.0,
    -0.5,  0.5,  0.5,  0.0,  1.0,  0.0,  0.0, 0.0,
    -0.5,  0.5, -0.5,  0.0,  1.0,  0.0,  0.0, 1.0
    })
	
	stride :: size_of(Vertex_Attributes)
    fmt.println("attr size ", size_of(Vertex_Attributes))


	fmt.println(size_of(f32) * len(vs))
	gl.GenBuffers(1, &VBO)
	gl.BindBuffer(gl.ARRAY_BUFFER, VBO)
	gl.BufferData(gl.ARRAY_BUFFER, size_of(Vertex_Attributes) * len(vs), raw_data(vs), gl.STATIC_DRAW)

	gl.GenVertexArrays(1, &CONTAINER_VAO)
	gl.BindVertexArray(CONTAINER_VAO)
	posLoc :: 0
	gl.VertexAttribPointer(posLoc, 3, gl.FLOAT, false, stride, 0)
	gl.EnableVertexAttribArray(posLoc)
	normalLoc :: 1
	gl.VertexAttribPointer(normalLoc, 3, gl.FLOAT, false, stride, 3 * size_of(f32))
	gl.EnableVertexAttribArray(normalLoc)
	uvLoc :: 2
	gl.VertexAttribPointer(uvLoc, 2, gl.FLOAT, false, stride, 6 * size_of(f32))
	gl.EnableVertexAttribArray(uvLoc)

    gl.GenVertexArrays(1, &LIGHT_VAO)
    gl.BindVertexArray(LIGHT_VAO)
	gl.VertexAttribPointer(posLoc, 3, gl.FLOAT, false, stride, 0)
	gl.EnableVertexAttribArray(posLoc)


	return true
}
