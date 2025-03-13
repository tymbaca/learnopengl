#version 410 core

in vec2 uv;

out vec4 FragColor;

uniform sampler2D ourTexture1;
uniform sampler2D ourTexture2;

void main()
{
    FragColor = mix(texture(ourTexture1, uv), texture(ourTexture2, uv), 0.5);
}
