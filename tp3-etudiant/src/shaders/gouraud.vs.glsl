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
    vec3 pos = (modelView * vec4(position, 1)).xyz;
    vec3 fakeLight0 = (view * vec4(lights[0].position, 1)).xyz - pos;
    vec3 fakeLight1 = (view * vec4(lights[1].position, 1)).xyz - pos;
    vec3 fakeLight2 = (view * vec4(lights[2].position, 1)).xyz - pos;    

    vec3 O = normalize(-pos);
    vec3 N = normalize((normalMatrix * normal));
    vec3 L0 = normalize(fakeLight0);
    vec3 L1 = normalize(fakeLight1);
    vec3 L2 = normalize(fakeLight2);

    vec3 ambientTemp;
    vec3 diffuseTemp;
    vec3 specularTemp;

    ambientTemp = mat.ambient * lightModelAmbient;
    for (int i = 0; i < 3; i++)
    {
        ambientTemp += mat.ambient * lights[i].ambient;
    }

    float NdotL0 = max(0.0, dot(N, L0));
    float NdotL1 = max(0.0, dot(N, L1));
    float NdotL2 = max(0.0, dot(N, L2));
    diffuseTemp = mat.diffuse * lights[0].diffuse * NdotL0;
    diffuseTemp += mat.diffuse * lights[1].diffuse * NdotL1;
    diffuseTemp += mat.diffuse * lights[2].diffuse * NdotL2;

    float spec0;
    float spec1;
    float spec2;
    if (useBlinn)
    {
        spec0 = max(0.0, dot(normalize(L0 + O), N));
        spec1 = max(0.0, dot(normalize(L1 + O), N));
        spec2 = max(0.0, dot(normalize(L2 + O), N));
    }
    else
    {
        spec0 = max(0.0, dot(reflect(-L0, N), O));
        spec1 = max(0.0, dot(reflect(-L1, N), O));
        spec2 = max(0.0, dot(reflect(-L2, N), O));
    }
    specularTemp = mat.specular * lights[0].specular * pow(spec0, mat.shininess);
    specularTemp += mat.specular * lights[1].specular * pow(spec1, mat.shininess);
    specularTemp += mat.specular * lights[2].specular * pow(spec2, mat.shininess);

    gl_Position = mvp * vec4(position, 1);
    attribOut.texCoords = texCoords;
    attribOut.ambient = ambientTemp;
    attribOut.diffuse = diffuseTemp;
    attribOut.specular = specularTemp;
    attribOut.emission = mat.emission;
}
