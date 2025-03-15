package shader

import "core:fmt"
import "core:reflect"
import "core:testing"
import "core:image"
import "core:image/png"
import "core:log"
import "core:slice"
import gl "vendor:OpenGL"

Texture :: struct {
	id:     u32,
	width:  int,
	height: int,
}

load_texture :: proc(path: string, with_alpha := true, mirror_vertically := true, generate_mipmap := true) -> (texture: Texture, ok: bool) {
    opts: image.Options = {.alpha_add_if_missing} if with_alpha else {}
	img, err := image.load_from_file(path, opts)
	if err != nil {
		log.error(err)
		return {}, false
	}
	defer image.destroy(img)

    if mirror_vertically {
        mirror_image_vertically(img.pixels.buf[:], img.width, img.height, with_alpha)
    }

	texture_id: u32
	gl.GenTextures(1, &texture_id)
	gl.BindTexture(gl.TEXTURE_2D, texture_id)

	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR)
	gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)

    format: u32 = gl.RGBA if with_alpha else gl.RGB
	gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, auto_cast img.width, auto_cast img.height, 0, format, gl.UNSIGNED_BYTE, raw_data(img.pixels.buf))

	if generate_mipmap {
		gl.GenerateMipmap(gl.TEXTURE_2D)
	}

	return {id = texture_id, width = img.width, height = img.height}, true
}

mirror_image_vertically :: proc(bytes: []byte, width, height: int, with_alpha := false) {
    pixel_width := 4 if with_alpha else 3
    row_len := pixel_width * width

    // 0 1 2 3 4 // 5 / 2 = 2
    // 0 1 2 3 // 4 / 2 = 2
    mirror_slice_vertically(bytes, row_len, height)
}

mirror_slice_vertically :: proc(s: []$T, width, height: int) {
    assert(len(s) == width * height)

    for i in 0..<height/2 {
        left_row := s[i*width:(i+1)*width]

        j := height-1-i
        right_row := s[j*width:(j+1)*width]

        swap_slices(left_row, right_row)
    }
}

@(test)
mirror_image_vertically_test :: proc(t: ^testing.T) {
    {
        width := 3
        height := 4
        data := []byte{
            11, 11, 11, 12, 12, 12, 13, 13, 13,
            21, 21, 21, 22, 22, 22, 23, 23, 23,
            31, 31, 31, 32, 32, 32, 33, 33, 33,
            41, 41, 41, 42, 42, 42, 43, 43, 43,
        }

        mirror_image_vertically(data, width, height, false)

        testing.expect(t, slice.equal(data, []byte{
            41, 41, 41, 42, 42, 42, 43, 43, 43,
            31, 31, 31, 32, 32, 32, 33, 33, 33,
            21, 21, 21, 22, 22, 22, 23, 23, 23,
            11, 11, 11, 12, 12, 12, 13, 13, 13,
        }))
    }

    {
        width := 3
        height := 3
        data := []byte{
            11, 11, 11, 12, 12, 12, 13, 13, 13,
            21, 21, 21, 22, 22, 22, 23, 23, 23,
            31, 31, 31, 32, 32, 32, 33, 33, 33,
        }

        mirror_image_vertically(data, width, height, false)

        testing.expect(t, slice.equal(data, []byte{
            31, 31, 31, 32, 32, 32, 33, 33, 33,
            21, 21, 21, 22, 22, 22, 23, 23, 23,
            11, 11, 11, 12, 12, 12, 13, 13, 13,
        }))
    }
}

swap_slices :: proc(a, b: []byte) {
    assert(len(a) == len(b))

    for _, i in a {
        a[i], b[i] = b[i], a[i]
    }
}

@(test)
swap_slices_test :: proc(t: ^testing.T) {
    a := []byte{1, 2, 3, 4}
    b := []byte{5, 6, 7, 8}
    swap_slices(a, b)
    
    testing.expect(t, slice.equal(a, []byte{5, 6, 7, 8}))
    testing.expect(t, slice.equal(b, []byte{1, 2, 3, 4}))
}
