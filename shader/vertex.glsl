#version 410 core
layout (location = 0) in vec3 pos;
layout (location = 1) in vec4 aColor;
layout (location = 2) in vec2 aUV;
layout (location = 3) in float scale;

uniform float globalScale;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec4 color;
out vec2 uv;
out float factor;

void main()
{
    vec3 modPos = pos * scale * globalScale;

    // mat4 M = mat4(
    //     vec4(1.0, 0.0, 0.0, 0.0),
    //     vec4(0.0, 1.0, 0.0, 0.0),
    //     vec4(0.0, 0.0, 1.0, 0.0),
    //     vec4(0.0, 0.0, 0.0, 1.0)
    // );
    // gl_Position = M * vec4(modPos, 1.0);
    gl_Position = projection * view * model * vec4(modPos, 1.0);
    // gl_Position = vec4(modPos, 1.0);
    color = aColor;
    uv = aUV;
    factor = globalScale;
}
