#version 330 core

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

in ATTRIB_OUT
{
    vec3 position;
    vec2 texCoords;
} attribIn[];

out ATTRIB_VS_OUT
{
    vec2 texCoords;    
    vec3 emission;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
} attribOut;

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

vec3 calculateNormal() {
    vec4 pos1 = modelView * vec4(attribIn[0].position, 1);
    vec4 pos2 = modelView * vec4(attribIn[1].position, 1);
    vec4 pos3 = modelView * vec4(attribIn[2].position, 1);
    vec3 side1 = pos2.xyz - pos1.xyz;
    vec3 side2 = pos3.xyz - pos1.xyz;
    return normalize(normalMatrix * cross(side1, side2));
}

void main()
{
    for (int i = 0; i < 3; i++) {
        attribOut.texCoords = attribIn[i].texCoords;
        attribOut.ambient = vec3(1.0, 0.0, 0.0); // Red color for debugging
        attribOut.emission = vec3(0.0);
        attribOut.diffuse = vec3(0.0);
        attribOut.specular = vec3(0.0);
        EmitVertex();
    }
    
    EndPrimitive();
}

