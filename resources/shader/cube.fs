#version 410 core

struct Material {
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

struct Light {
    vec3 position;

    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

in vec3 Normal;
in vec2 UV;
in vec3 FragPos; // in world space

out vec4 FragColor;

uniform Light light;
uniform bool useSpec;
uniform vec3 viewPos;

uniform Material material;

vec4 getAmbient(Light light) 
{
    return vec4(light.ambient, 1); // TODO: distance
}

vec4 getDiffuse(vec3 fragPos, vec3 normal, Light light)
{
    normal = normalize(normal);
    vec3 toLight = light.position - fragPos;
    float distance = length(toLight);
    // `-1 to 0` - dark side, `0 to 1` - light side
    float factor = dot(normalize(toLight), normalize(normal));

    factor = max(factor, 0.0); // so that dark side will remain ambient (not become more dark)
    vec3 resultLight = light.diffuse * factor;

    return vec4(resultLight, 1.0);
}

vec4 getSpecular(vec3 fragPos, vec3 normal, Light light, vec3 viewPos, vec3 strength, float shininess)
{
    vec3 toLight = light.position - fragPos;
    vec3 toReflect = reflect(-toLight, normal);

    vec3 toView = viewPos - fragPos;
    
    float factor = max(dot(normalize(toReflect), normalize(toView)), 0.0);
    factor = pow(factor, shininess); // less = more rough

    return vec4(light.specular * strength * factor, 1.0);
}

void main()
{
    vec4 albedo = texture(material.diffuse, UV);
    vec3 specularFactor = vec3(texture(material.specular, UV));
    if (!useSpec) {
        specularFactor = vec3(1);
    }

    vec4 ambientLight = getAmbient(light);
    vec4 diffuseLight = getDiffuse(FragPos, Normal, light);
    vec4 specularLight = getSpecular(FragPos, Normal, light, viewPos, specularFactor, material.shininess);

    FragColor = (ambientLight + diffuseLight + specularLight) * albedo;
}
