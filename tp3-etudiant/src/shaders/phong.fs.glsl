#version 330 core

in ATTRIB_VS_OUT
{
    vec2 texCoords;
    vec3 normal;
    vec3 lightDir[3];
    vec3 spotDir[3];
    vec3 obsPos;
} attribIn;

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

uniform sampler2D diffuseSampler;
uniform sampler2D specularSampler;

out vec4 FragColor;

void main()
{
    // TODO
    vec3 O = normalize(attribIn.obsPos);
    vec3 N = normalize(attribIn.normal);
    vec3 L0 = normalize(attribIn.lightDir[0]);
    vec3 L1 = normalize(attribIn.lightDir[1]);
    vec3 L2 = normalize(attribIn.lightDir[2]);

    vec4 texture = texture2D(diffuseSampler, attribIn.texCoords);
    vec3 ambientTemp;
    vec3 diffuseTemp;
    vec3 specularTemp;

    ambientTemp = mat.emission + mat.ambient * lightModelAmbient;
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

    FragColor = vec4(ambientTemp + diffuseTemp + specularTemp, 1);
    // FragColor = vec4(diffuseTemp, 1);
}
