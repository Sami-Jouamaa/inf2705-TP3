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
    vec3 pos1 = attribIn[0].position;
    vec3 pos2 = attribIn[1].position;
    vec3 pos3 = attribIn[2].position;
    vec3 side1 = pos2 - pos1;
    vec3 side2 = pos3 - pos1;
    return normalize(normalMatrix * cross(side1, side2));
}

vec3 specularBlinn(in vec3 lightDir, in vec3 faceNormal, in vec3 obsDir, in UniversalLight light, in float spotFactor) {
    vec3 halfwayVector = normalize(lightDir + obsDir);
    float intensity = pow(max(dot(faceNormal, halfwayVector), 0.0), mat.shininess);
    return  mat.specular * light.specular * intensity * spotFactor;
}

vec3 specularPhong(in vec3 lightDir, in vec3 faceNormal, in vec3 obsDir, in UniversalLight light, in float spotFactor) {
    vec3 reflectionDir = reflect(-lightDir, faceNormal);
    float intensity = pow(max(dot(obsDir, reflectionDir), 0.0), mat.shininess);
    return mat.specular * light.specular * intensity * spotFactor;
}

void main()
{
    // Calucation of face values
    vec3 faceNormal = calculateNormal();
    vec3 center = (modelView * vec4((attribIn[0].position + attribIn[1].position + attribIn[2].position) / 3.0, 1)).xyz;
    
    // Initialisation of light colors
    vec3 ambientColor = mat.ambient * lightModelAmbient;
    vec3 diffuseColor = vec3(0.0);
    vec3 specularColor = vec3(0.0);

    // direction vector to observer for specular

    for (int i = 0; i < 3; i++) {
        UniversalLight light = lights[i];
        ambientColor += mat.ambient * light.ambient;
        vec3 lightDir = normalize((view * vec4(light.position, 1)).xyz - center);
        float spotFactor = 1.0;
        if (useSpotlight) {
            float cosGamma = dot(lightDir, light.spotDirection);
            float minVal = cos(radians(spotOpeningAngle));
            if (cosGamma < minVal) {
                spotFactor = 0.0;
            }
            else {
                if (useDirect3D) {
                float inner = min(minVal * 1.5, 1.0);
                spotFactor = smoothstep(minVal, minVal + inner, cosGamma);
                } else {
                spotFactor = pow(cosGamma, spotExponent);
                }
            }
        }
        diffuseColor += mat.diffuse * light.diffuse * max(dot(faceNormal, lightDir), 0.0) * spotFactor;
        vec3 obsDir = normalize(-center);
        if (useBlinn) {
            specularColor += specularBlinn(lightDir, faceNormal, obsDir, light, spotFactor);
        } else {
            specularColor += specularPhong(lightDir, faceNormal, obsDir, light, spotFactor);
        }
    }

    for (int i = 0; i < 3; i++) {
        attribOut.texCoords = attribIn[i].texCoords;
        attribOut.ambient = ambientColor;
        attribOut.emission = mat.emission;
        attribOut.diffuse = diffuseColor;
        attribOut.specular = specularColor;
        gl_Position = gl_in[i].gl_Position;
        EmitVertex();
    }
    
    EndPrimitive();
}
