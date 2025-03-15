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

vec4 getDeffuse(vec3 fragPos, vec3 normal, vec3 lightPos, vec3 lightColor)
{
    vec3 toLight = lightPos - fragPos;
    float factor = dot(toLight, normal);
    vec3 resultLight = lightColor * factor;

    return vec4(resultLight, 1);
}

void main()
{
    vec4 color = mix(texture(ourTexture1, UV), texture(ourTexture2, UV), 0.5);
    vec4 ambient = vec4(ambientLight, 1);
    vec4 deffuse = getDeffuse(FragPos, Normal, lightPos, lightColor);
    FragColor = color * ambient * deffuse;
}
