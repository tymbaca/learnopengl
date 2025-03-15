#version 410 core

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec2 aUV;

uniform mat4 modelMat;
uniform mat3 normalMat;
uniform mat4 viewMat;
uniform mat4 projectionMat;

out vec3 Normal;
out vec2 UV;
out vec3 FragPos; // in world space

void main()
{
    gl_Position = projectionMat * viewMat * modelMat * vec4(aPos, 1.0);
    Normal = normalMat * aNormal;
    UV = aUV;
    FragPos = vec3(modelMat * vec4(aPos, 1.0));
}
