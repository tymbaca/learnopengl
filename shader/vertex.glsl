#version 410 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aUV;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

out vec4 color;
out vec2 uv;
out float factor;

void main()
{
    gl_Position = projection * view * model * vec4(aPos, 1.0);
    uv = aUV;
}
