#version 410 core

in vec3 Normal;
in vec2 UV;
in vec3 FragPos; // in world space

out vec4 FragColor;

uniform sampler2D ourTexture1;
uniform sampler2D ourTexture2;
uniform vec3 ambientLight;
uniform vec3 lightPos;
uniform vec3 lightColor;

void main()
{
    vec4 color = mix(texture(ourTexture1, UV), texture(ourTexture2, UV), 0.5);
    vec4 ambient = vec4(ambientLight, 1);
    // vec4 deffuse = 
    FragColor = color * ambient * vec4(FragPos, 1);
}
