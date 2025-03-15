#version 410 core

in vec3 Normal;
in vec2 UV;

out vec4 FragColor;

uniform sampler2D ourTexture1;
uniform sampler2D ourTexture2;
uniform vec3 ambientLight;

void main()
{
    FragColor = mix(texture(ourTexture1, UV), texture(ourTexture2, UV), 0.5) * vec4(ambientLight, 1);
}
