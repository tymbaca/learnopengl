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
    normal = normalize(normal);
    vec3 toLight = lightPos - fragPos;
    float distance = length(toLight);
    // `-1 to 0` - dark side, `0 to 1` - light side
    float factor = dot(normalize(toLight), normalize(normal));

    factor = max(factor, 0.0); // so that dark side will remain ambient (not become more dark)
    vec3 resultLight = lightColor * factor * 5;

    resultLight /= distance;

    return vec4(resultLight, 1.0);
}

void main()
{
    vec4 color = mix(texture(ourTexture1, UV), texture(ourTexture2, UV), 0.5);
    vec4 ambient = vec4(ambientLight, 1);
    vec4 deffuse = getDeffuse(FragPos, Normal, lightPos, lightColor);

    FragColor = (ambient + deffuse) * color;
}
