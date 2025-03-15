package shader

import "core:math/linalg"
import "core:fmt"
import "core:os"
import "core:strings"
import "core:testing"
import gl "vendor:OpenGL"

Program :: struct {
	id: u32,
}

new :: proc(vertex_path, frag_path: string) -> (program: Program, ok: bool) {
	context.allocator = context.temp_allocator
	defer free_all(context.allocator)

	vertex := shader_from_filename(vertex_path, .VERTEX_SHADER) or_return
	defer gl.DeleteShader(vertex)
	fragment := shader_from_filename(frag_path, .FRAGMENT_SHADER) or_return
	defer gl.DeleteShader(fragment)

	program_id := gl.create_and_link_program({vertex, fragment}) or_return

	return Program{id = program_id}, true
}

use :: proc(p: Program) {
	gl.UseProgram(p.id)
}

set :: proc(p: Program, name: cstring, val: $T) {
    val := val
	loc := gl.GetUniformLocation(p.id, name)

    when T == f32 {
        gl.Uniform1f(loc, val)
    } else when T == [2]f32 {
        gl.Uniform2f(loc, val.x, val.y)
    } else when T == [3]f32 {
        gl.Uniform3f(loc, val.x, val.y, val.z)
    } else when T == [4]f32 {
        gl.Uniform4f(loc, val.x, val.y, val.z, val.w)
    } else when T == i32 {
        gl.Uniform1i(loc, val)
    } else when T == matrix[4,4]f32 {
        gl.UniformMatrix4fv(loc, 1, false, cast([^]f32)(&val))
    } else when T == matrix[3,3]f32 {
        gl.UniformMatrix3fv(loc, 1, false, cast([^]f32)(&val))
    }
}

shader_from_filename :: proc(
	path: string,
	shader_type: gl.Shader_Type,
) -> (
	shader: u32,
	ok: bool,
) {
	bytes := os.read_entire_file(path) or_return
	str := string(bytes)
	return gl.compile_shader_from_source(str, shader_type)
}
