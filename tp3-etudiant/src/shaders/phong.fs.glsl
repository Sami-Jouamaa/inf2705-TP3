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

vec3 calculateDiffuseTemp(vec3 N, float[3] spotFactors)
{
    vec3 diffuseResult = vec3(0);
    for (int i = 0; i < 3; i++)
    {
        vec3 L = normalize(attribIn.lightDir[i]);
        float NdotL = max(0.0, dot(N, L));
        diffuseResult += mat.diffuse * lights[i].diffuse * NdotL * spotFactors[i];
    }
    return diffuseResult;
}

vec3 calculateSpecularBlinn(vec3 O, vec3 N, float[3] spotFactors)
{
    vec3 specularResult = vec3(0);
    for (int i = 0; i < 3; i++)
    {
        vec3 L = normalize(attribIn.lightDir[i]);
        float spec = max(0.0, dot(normalize(L + O), N));
        specularResult += mat.specular * lights[i].specular * pow(spec, mat.shininess) * spotFactors[i];
    }
    return specularResult;
}

vec3 calculateNormalSpecular(vec3 O, vec3 N, float[3] spotFactors)
{
    vec3 specularResult = vec3(0);
    for (int i = 0; i < 3; i++)
    {
        vec3 L = normalize(attribIn.lightDir[i]);
        float spec = max(0.0, dot(reflect(-L, N), O));
        specularResult += mat.specular * lights[i].specular * pow(spec, mat.shininess) * spotFactors[i];
    }
    return specularResult;
}

vec3 calculateSpotDiffuse(vec3 O, vec3 N)
{
    vec3 diffuseResult = vec3(0);
    for (int i = 0; i < 3; i++)
    {
        vec3 L = normalize(attribIn.spotDir[i]);
        float angle = max(0.0, dot(L, N));
        if (angle < spotOpeningAngle)
        {
            diffuseResult += mat.diffuse * lights[i].diffuse * pow(cos(angle), spotExponent);
        }
        else
        {
            continue;
        }
    }
    return diffuseResult * vec3(texture(diffuseSampler, attribIn.texCoords));
}

vec3 calculateSpotNormalSpecular(vec3 O, vec3 N)
{
    vec3 specularResult = vec3(0);
    for (int i = 0; i < 3; i++)
    {
        vec3 L = normalize(attribIn.spotDir[i]);
        vec3 D = normalize(lights[i].spotDirection);
        float angle = dot(L, D); // angle seems to be one, when only returning angle, the ball is white
        // something like that, everything is black though
        if (angle < cos(spotOpeningAngle))
        {
            continue;
        }
        else
        {
            if (useBlinn)
            {
                float factor = pow(angle, spotExponent);
                float spec = max(0.0, dot(normalize(L + O), N));
                specularResult += mat.specular * lights[i].specular * pow(spec, mat.shininess) * factor;
            }
            else
            {
                float factor = pow(angle, spotExponent);
                float spec = max(0.0, dot(reflect(-L, N), O));
                specularResult += mat.specular * lights[i].specular * pow(spec, mat.shininess) * factor;
            }
        }
    }
    return specularResult * vec3(texture(specularSampler, attribIn.texCoords));
}

void main()
{
    // TODO
    vec3 O = normalize(attribIn.obsPos);
    vec3 N = normalize(attribIn.normal);
    vec4 texture = texture(diffuseSampler, attribIn.texCoords);
    vec3 specularTemp = vec3(0.0);
    float[3] spotFactors = [1.0, 1.0, 1.0];
    if (useSpotlight) {
        for (int i = 0; i < 3; i++) {
            vec3 spotDir = attribIn.spotDir[i];
            float cosGamma = max(dot(-lightDir[i], normalize(spotDirectionView)), 0.0);
            float maxCos = max(cos(radians(spotOpeningAngle)), 0.0);
            if (cosGamma < maxCos) {
                spotFactors[i] = 0.0;
            } else {
                if (useDirect3D) {
                    float cosInner = min(maxCos * 2, 1.0);
                    spotFactors[i] = smoothstep(maxCos, cosInner, cosGamma);
                } else {
                    spotFactors[i] = pow(cosGamma, spotExponent);
                }
            }
        }
    } 

    vec3 ambientTemp = calculateAmbientTemp();
    vec3 diffuseTemp = calculateDiffuseTemp(N, spotFactors);
    if (useBlinn) {
        specularTemp = calculateSpecularBlinn(O, N, spotFactors);
    }
    else {
        specularTemp = calculateNormalSpecular(O, N, spotFactors);
    }

    FragColor = vec4(ambientTemp + diffuseTemp + specularTemp, 1);
}
