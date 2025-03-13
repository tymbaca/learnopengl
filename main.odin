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
WIDTH :: 512
HEIGHT :: 512

GL_MAJOR_VERSION: c.int : 4
GL_MINOR_VERSION :: 1

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

	window := glfw.CreateWindow(WIDTH, HEIGHT, PROGRAMNAME, nil, nil)
	defer glfw.DestroyWindow(window)

	if window == nil {
		fmt.println("Unable to create window")
		return
	}

	glfw.MakeContextCurrent(window)

	glfw.SwapInterval(1)

	glfw.SetKeyCallback(window, key_callback)

	glfw.SetFramebufferSizeCallback(window, size_callback)

	gl.load_up_to(int(GL_MAJOR_VERSION), GL_MINOR_VERSION, glfw.gl_set_proc_address)

	if ok := init(); !ok {
        fmt.println("can't init")
        return
    }

	for (!glfw.WindowShouldClose(window) && _running) {
		glfw.PollEvents()

		update()
		draw()

		glfw.SwapBuffers((window))
	}

	exit()

}

update :: proc() {
	// Own update code here
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
