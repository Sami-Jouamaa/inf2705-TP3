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

void specularBlinn(inout vec3 specularColor, in vec3 lightDir, in vec3 faceNormal, inout vec3 obsDir) {
    vec3 halfwayVector = normalize(lightDir + obsDir);
    float intensity = pow(max(dot(faceNormal, halfwayVector), 0.0), mat.shininess);
    specularColor += mat.specular * light.specular * intensity;
}

void specularPhong(inout vec3 specularColor, in vec3 lightDir, in vec3 faceNormal, inout vec3 obsDir) {
    vec3 reflectionDir = reflect(-lightDir, faceNormal);
    float intensity = pow(max(dot(obsDir, reflectionDir), 0.0), mat.shininess);
    specularColor += mat.specular * light.specular * intensity;
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
        vec3 lightDir = normalize((view * vec4(light.position, 1)).xyz - center);

        ambientColor += mat.ambient * light.ambient;
        diffuseColor += mat.diffuse * light.diffuse * max(dot(faceNormal, lightDir), 0.0);
        vec3 obsDir = normalize(-center);
        if (useBlinn) {
            specularBlinn(specularColor, lightDir, faceNormal, obsDir);
        } else {
            specularPhong(specularColor, lightDir, faceNormal, obsDir);
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
