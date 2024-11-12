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
    vec3 side1 = position[1] - position[0];
    vec3 side2 = position[2] - position[0];
    return normalize(normalMatrix * cross(side1, side2));
}

void main()
{
    Material material = LightingBlock.mat;

    // Calucation of face values
    vec3 faceNormal = calculateNormal();
    vec3 center = modelView * ((attribIn[0].position + attribIn[1].position + attribIn[2].position) / 3.0);
    
    // Initialisation of light colors
    vec3 ambientColor = material.ambient * LightingBlock.lightModelAmbient;
    vec3 diffuseColor = vec3(0.0);
    vec3 specularColor = vec3(0.0);

    // direction vector to observer for specular
    vec3 obsDir = normalize(-center);

    for (int i = 0; i < 3; i++) {
        UniversalLight light = LightingBlock.lights[i];
        vec3 lightDir = normalize((view * vec4(light.position, 1)).xyz - center);

        ambientColor += material.ambient * light.ambient;
        diffuseColor += material.diffuse * light.diffuse * max(dot(faceNormal, lightDir), 0.0);
        if (LightingBlock.useBlinn) {
            vec3 halfwayVector = normalize((lightDir + obsDir));
            float intensity = pow(max(dot(faceNormal, halfwayVector), 0.0), material.shininess);
            specularColor += material.specular * light.specular * intensity;
        } else {
            vec3 reflectionDir = reflect(-lightDir, faceNormal);
            float intensity = pow(max(dot(obsDir, reflectionDir), 0.0), material.shininess);
            specularColor += material.specular * light.specular * intensity;
        }
    }

    for (int i = 0; i < 3; i++) {
        attribOut.texCoords = attribIn[i].texCoords;
        attribOut.ambient = ambientColor;
        attribOut.emission = material.emission;
        attribOut.diffuse = diffuseColor;
        attribOut.specular = specularColor;
        EmitVertex();
    }
    
    EndPrimitive();
}
