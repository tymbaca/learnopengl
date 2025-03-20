#version 410 core

struct Material {
    sampler2D diffuse;
    sampler2D specular;
    float shininess;
};

const int directionalLightTag = 1;
const int pointLightTag = 2;
const int spotLightTag = 3;

struct Light {
    int tag; 
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;

    vec3 position;
    vec3 direction;

    float constant;
    float linear;
    float quadratic;

    float angle; // cosine of the actual angle
};

in vec3 Normal;
in vec2 UV;
in vec3 FragPos; // in world space

out vec4 FragColor;

uniform Light light;
uniform bool useSpec;
uniform vec3 viewPos;

uniform Material material;

float getAttenuation(float distance, float constant, float linear, float quadratic)
{
    return 1.0 / (constant + (linear * distance) + (quadratic * distance * distance));
}

float getSpottedFactor(vec3 fragPos, Light light) 
{
    vec3 toFragDir = fragPos - light.position;
    float angle = dot(normalize(light.direction), normalize(toFragDir));

    if (angle < light.angle) {
        return 0;
    }

    return 1;
}

vec4 getAmbientDiractional(Light light) 
{
    return vec4(light.ambient, 1);
}

vec4 getAmbientPoint(vec3 fragPos, Light light) 
{
    float dist = distance(fragPos, light.position);
    vec3 ambient = light.ambient * getAttenuation(dist, light.constant, light.linear, light.quadratic);
    return vec4(ambient, 1);
}

vec4 getAmbientSpot(vec3 fragPos, Light light) 
{
    float spotted = 1;
    // float spotted = getSpottedFactor(fragPos, light);
    float dist = distance(fragPos, light.position);
    vec3 ambient = light.ambient * getAttenuation(dist, light.constant, light.linear, light.quadratic);
    return vec4(ambient * spotted, 1);
}

vec4 getAmbient(vec3 fragPos, Light light) 
{
    switch (light.tag) {
        case directionalLightTag:
            return getAmbientDiractional(light);
        case pointLightTag:
            return getAmbientPoint(fragPos, light);
        case spotLightTag:
            return getAmbientSpot(fragPos, light);
    }

    return vec4(0,0,0,1);
}

vec4 getDiffuseDiractional(vec3 fragPos, vec3 normal, Light light)
{
    vec3 toLight = -light.direction;
    // `-1 to 0` - dark side, `0 to 1` - light side
    float factor = dot(normalize(toLight), normalize(normal));

    vec3 resultLight = light.diffuse * max(factor, 0.0); // so that dark side will remain ambient (not become more dark)

    return vec4(resultLight, 1.0);
}

vec4 getDiffusePoint(vec3 fragPos, vec3 normal, Light light)
{
    normal = normalize(normal);
    vec3 toLight = light.position - fragPos;
    float distance = length(toLight);
    // `-1 to 0` - dark side, `0 to 1` - light side
    float factor = dot(normalize(toLight), normalize(normal));

    factor = max(factor, 0.0); // so that dark side will remain ambient (not become more dark)
    vec3 resultLight = light.diffuse * factor;

    // apply distance
    resultLight *= getAttenuation(distance, light.constant, light.linear, light.quadratic);

    return vec4(resultLight, 1.0);
}

vec4 getDiffuseSpot(vec3 fragPos, vec3 normal, Light light)
{
    float spotted = getSpottedFactor(fragPos, light);
    if (spotted == 0) {
        return vec4(0,0,0,1);
    }

    normal = normalize(normal);
    vec3 toLight = light.position - fragPos;
    float distance = length(toLight);
    // `-1 to 0` - dark side, `0 to 1` - light side
    float factor = dot(normalize(toLight), normalize(normal));

    factor = max(factor, 0.0); // so that dark side will remain ambient (not become more dark)
    vec3 resultLight = light.diffuse * factor;

    // apply distance
    resultLight *= getAttenuation(distance, light.constant, light.linear, light.quadratic);

    return vec4(resultLight * spotted, 1.0);
}

vec4 getDiffuse(vec3 fragPos, vec3 normal, Light light)
{
    switch (light.tag) {
        case directionalLightTag:
            return getDiffuseDiractional(fragPos, normal, light);
        case pointLightTag:
            return getDiffusePoint(fragPos, normal, light);
        case spotLightTag:
            return getDiffuseSpot(fragPos, normal, light);
    }

    return vec4(0,0,0,1);
}

vec4 getSpecularDirectional(vec3 fragPos, vec3 normal, Light light, vec3 viewPos, vec3 strength, float shininess)
{
    vec3 toLight = -light.direction;
    vec3 toReflect = reflect(-toLight, normal);

    vec3 toView = viewPos - fragPos;
    
    float factor = max(dot(normalize(toReflect), normalize(toView)), 0.0);
    factor = pow(factor, shininess); // less = more rough

    return vec4(light.specular * strength * factor, 1.0);
}

vec4 getSpecularPoint(vec3 fragPos, vec3 normal, Light light, vec3 viewPos, vec3 strength, float shininess)
{
    vec3 toLight = light.position - fragPos;
    vec3 toReflect = reflect(-toLight, normal);

    vec3 toView = viewPos - fragPos;
    
    float factor = max(dot(normalize(toReflect), normalize(toView)), 0.0);
    factor = pow(factor, shininess); // less = more rough

    return vec4(light.specular * strength * factor, 1.0);
}

vec4 getSpecularSpot(vec3 fragPos, vec3 normal, Light light, vec3 viewPos, vec3 strength, float shininess)
{
    float spotted = getSpottedFactor(fragPos, light);
    if (spotted == 0) {
        return vec4(0,0,0,1);
    }

    vec3 toLight = light.position - fragPos;
    vec3 toReflect = reflect(-toLight, normal);

    vec3 toView = viewPos - fragPos;
    
    float factor = max(dot(normalize(toReflect), normalize(toView)), 0.0);
    factor = pow(factor, shininess); // less = more rough

    return vec4(light.specular * strength * factor * spotted, 1.0);
}

vec4 getSpecular(vec3 fragPos, vec3 normal, Light light, vec3 viewPos, vec3 strength, float shininess)
{
    switch (light.tag) {
        case directionalLightTag:
            return getSpecularDirectional(fragPos, normal, light, viewPos, strength, shininess);
        case pointLightTag:
            return getSpecularPoint(fragPos, normal, light, viewPos, strength, shininess);
        case spotLightTag:
            return getSpecularSpot(fragPos, normal, light, viewPos, strength, shininess);
    }

    return vec4(0,0,0,1);
}

void main()
{
    vec4 albedo = texture(material.diffuse, UV);
    vec3 specularFactor = vec3(texture(material.specular, UV));
    if (!useSpec) {
        specularFactor = vec3(1);
    }

    vec4 ambientLight = getAmbient(FragPos, light);
    vec4 diffuseLight = getDiffuse(FragPos, Normal, light);
    vec4 specularLight = getSpecular(FragPos, Normal, light, viewPos, specularFactor, material.shininess);

    FragColor = (ambientLight + diffuseLight + specularLight) * albedo;
}
