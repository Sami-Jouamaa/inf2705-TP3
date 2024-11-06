#version 330 core

layout (location = 0) in vec3 position;
layout (location = 1) in vec2 texCoords;
layout (location = 2) in vec3 normal;

out ATTRIB_VS_OUT
{
    vec2 texCoords;
    vec3 emission;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
} attribOut;

uniform mat4 mvp;
uniform mat4 view;
uniform mat4 modelView;
uniform mat3 normalMatrix;

struct Material
{
    vec3 emission;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;
};

struct UniversalLight
{
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    vec3 position;
    vec3 spotDirection;
};

layout (std140) uniform LightingBlock
{
    Material mat;
    UniversalLight lights[3];
    vec3 lightModelAmbient;
    bool useBlinn;
    bool useSpotlight;
    bool useDirect3D;
    float spotExponent;
    float spotOpeningAngle;
};

void main()
{
    // TODO
    vec3 pos = (modelView * vec4(position,1)).xyz;
    vec3 O = normalize(-pos);
    vec3 N = normalize(normalMatrix * normal);
    vec3 L0 = normalize((view * vec4(lights[0].position, 0)).xyz - pos);
    vec3 L1 = normalize((view * vec4(lights[1].position, 0)).xyz - pos);
    vec3 L2 = normalize((view * vec4(lights[1].position, 0)).xyz - pos);

    gl_Position = mvp * vec4(pos, 1);
    attribOut.texCoords = texCoords;
}
