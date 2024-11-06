#version 330 core

in ATTRIB_VS_OUT
{
    vec2 texCoords;
    vec3 emission;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
} attribIn;

uniform sampler2D diffuseSampler;
uniform sampler2D specularSampler;

out vec4 FragColor;

void main()
{
    // TODO
    FragColor = vec4(attribIn.ambient, 1);
    FragColor = vec4(attribIn.diffuse, 1);
    FragColor = vec4((attribIn.specular * attribIn.emission) , 1);
}
