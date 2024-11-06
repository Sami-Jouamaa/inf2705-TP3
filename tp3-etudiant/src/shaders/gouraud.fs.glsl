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
    vec4 specularTexture = texture(specularSampler, attribIn.texCoords);
    vec4 texture = texture(diffuseSampler, attribIn.texCoords);
    vec3 colour = vec3(0);
    colour += attribIn.ambient;
    colour += attribIn.diffuse;
    colour *= texture.rgb;
    colour += attribIn.emission;
    colour += attribIn.specular * specularTexture[0];
    FragColor = vec4(colour, 1); 
}
