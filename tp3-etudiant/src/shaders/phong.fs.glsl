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

vec3 calculateAmbientTemp()
{
    vec3 ambientResult = mat.emission + mat.ambient * lightModelAmbient;
    for (int i = 0; i < 3; i++)
    {
        ambientResult += mat.ambient * lights[i].ambient;
    }
    return ambientResult;
}

vec3 calculateDiffuseTemp(vec3 N)
{
    vec3 diffuseResult = vec3(0);
    for (int i = 0; i < 3; i++)
    {
        vec3 L = normalize(attribIn.lightDir[i]);
        float NdotL = max(0.0, dot(N, L));
        diffuseResult += mat.diffuse * lights[i].diffuse * NdotL;
    }
    return diffuseResult;
}

vec3 calculateSpecularBlinn(vec3 O, vec3 N)
{
    vec3 specularResult = vec3(0);
    for (int i = 0; i < 3; i++)
    {
        vec3 L = normalize(attribIn.lightDir[i]);
        float spec = max(0.0, dot(normalize(L + O), N));
        specularResult += mat.specular * lights[i].specular * pow(spec, mat.shininess);
    }
    return specularResult;
}

vec3 calculateNormalSpecular(vec3 O, vec3 N)
{
    vec3 specularResult = vec3(0);
    for (int i = 0; i < 3; i++)
    {
        vec3 L = normalize(attribIn.lightDir[i]);
        float spec = max(0.0, dot(reflect(-L, N), O));
        specularResult += mat.specular * lights[i].specular * pow(spec, mat.shininess);
    }
    return specularResult;
}

void main()
{
    // TODO
    vec3 O = normalize(attribIn.obsPos);
    vec3 N = normalize(attribIn.normal);
    vec3 L0 = normalize(attribIn.lightDir[0]);
    vec3 L1 = normalize(attribIn.lightDir[1]);
    vec3 L2 = normalize(attribIn.lightDir[2]);

    vec4 texture = texture2D(diffuseSampler, attribIn.texCoords);
    vec3 ambientTemp = calculateAmbientTemp();
    vec3 diffuseTemp = calculateDiffuseTemp(N);
    vec3 specularTemp = vec3(0);
    if (useBlinn)
    {
        specularTemp = calculateSpecularBlinn(O, N);
    }
    else
    {
        specularTemp = calculateNormalSpecular(O, N);
    }

    FragColor = vec4(ambientTemp + diffuseTemp + specularTemp, 1);
}
