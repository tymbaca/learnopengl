package main

import "core:fmt"
import "core:c"
import gl "vendor:OpenGL"
import "vendor:glfw"
import "base:runtime"
import rl "vendor:raylib"
import "core:math"
import "core:time"
import "shader/program"

PROGRAMNAME :: "Program"
WIDTH :: 1500
HEIGHT :: 700

GL_MAJOR_VERSION: c.int : 4
GL_MINOR_VERSION :: 1

WINDOW: glfw.WindowHandle

VERTEX_SHADER :: "shader/vertex.glsl"
FRAGMENT_SHADER :: "shader/fragment.glsl"
PROGRAM: program.Program

_running: b32 = true
VAO: u32
VBO: u32
// EBO: u32
TEXTURES: [TextureKind]program.Texture

TextureKind :: enum {
    wall,
    container,
    awesomeface,
}

CAMERA := Camera{pos = {0,0,0}, dir = {1,0,0}, up = UP, look_at = vec3{0,0,0}}

START := time.now()

main :: proc() {
	if !glfw.Init() {
		fmt.println("Failed to initialize GLFW")
		return
	}
	defer glfw.Terminate()

    glfw.WindowHint(glfw.RESIZABLE, true)
	glfw.WindowHint(glfw.OPENGL_FORWARD_COMPAT, true)
	glfw.WindowHint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MAJOR, GL_MAJOR_VERSION)
	glfw.WindowHint(glfw.CONTEXT_VERSION_MINOR, GL_MINOR_VERSION)

	WINDOW = glfw.CreateWindow(WIDTH, HEIGHT, PROGRAMNAME, nil, nil)
	defer glfw.DestroyWindow(WINDOW)

	if WINDOW == nil {
		fmt.println("Unable to create WINDOW")
		return
	}

	glfw.MakeContextCurrent(WINDOW)

	glfw.SwapInterval(1)

	glfw.SetKeyCallback(WINDOW, key_callback)

	glfw.SetFramebufferSizeCallback(WINDOW, size_callback)

	gl.load_up_to(int(GL_MAJOR_VERSION), GL_MINOR_VERSION, glfw.gl_set_proc_address)

	if ok := init(); !ok {
        fmt.println("can't init")
        return
    }

    gl.Enable(gl.DEPTH_TEST)

	for (!glfw.WindowShouldClose(WINDOW) && _running) {
		glfw.PollEvents()

        gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

		update()
		draw()

		glfw.SwapBuffers((WINDOW))
	}

	exit()

}


exit :: proc() {
	// Own termination code here
}

// Called when glfw keystate changes
key_callback :: proc "c" (window: glfw.WindowHandle, key, scancode, action, mods: i32) {
	// Exit program on escape pressed
	if key == glfw.KEY_ESCAPE {
		_running = false
	}
}

// Called when glfw window changes size
size_callback :: proc "c" (window: glfw.WindowHandle, width, height: i32) {
	// Set the OpenGL viewport size
	gl.Viewport(0, 0, width, height)
}
