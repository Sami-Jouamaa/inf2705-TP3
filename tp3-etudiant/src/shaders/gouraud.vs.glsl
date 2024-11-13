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
    vec3 O = normalize(-pos);
    vec3 N = normalize((normalMatrix * normal));

    vec3 ambientTemp = mat.ambient * lightModelAmbient;
    vec3 diffuseTemp = vec3(0.0);
    vec3 specularTemp = vec3(0.0);

    for (int i = 0; i < 3; i++) {
        UniversalLight light = lights[i];
        ambientTemp += mat.ambient * light.ambient;

        vec3 L = normalize((view * vec4(lights[0].position, 1)).xyz - pos);
        float spotFactor = 1.0;
        if(useSpotlight) {
            vec3 spotDirectionView = normalize((view * vec4(light.spotDirection, 0.0)).xyz);
            float cosGamma = max(dot(-L, normalize(spotDirectionView)), 0.0);
            float maxCos = max(cos(radians(spotOpeningAngle)), 0.0);
            if (cosGamma < maxCos) {
                spotFactor = 0.0;
            } else {
                if (useDirect3D) {
                    float cosInner = min(maxCos * 2, 1.0);
                    spotFactor = smoothstep(maxCos, cosInner, cosGamma);
                } else {
                    spotFactor = pow(cosGamma, spotExponent);
                }
            }
        }
        float NdotL = max(0.0, dot(N, L));
        diffuseTemp += mat.diffuse * light.diffuse * NdotL * spotFactor;
        float specFact;
        if (useBlinn) {
            specFact = max(0.0, dot(normalize(L + O), N));
        } else {
            specFact = max(0.0, dot(reflect(-L, N), O));
        }
        specularTemp += mat.specular * light.specular * pow(specFact, mat.shininess) * spotFactor;
    }

    gl_Position = mvp * vec4(position, 1);
    attribOut.texCoords = texCoords;
    attribOut.ambient = ambientTemp;
    attribOut.diffuse = diffuseTemp;
    attribOut.specular = specularTemp;
    attribOut.emission = mat.emission;
}
