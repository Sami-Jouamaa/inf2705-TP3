#include "resources.h"

#include "utils.h"

#include "shader_object.h"

#include "vertices_data.h"
#include <iostream>

#include "../corrector/shaders_strings.h"

Resources::Resources()
{
    //initShaderProgram(model, "shaders/model.vs.glsl", "shaders/model.fs.glsl");
    
    ShaderObject vertex(GL_VERTEX_SHADER, readFile("shaders/phong.vs.glsl").c_str());
    ShaderObject fragment(GL_FRAGMENT_SHADER, readFile("shaders/phong.fs.glsl").c_str());
    phong.attachShaderObject(vertex);
    phong.attachShaderObject(fragment);
    phong.link();
        
    phong.use();
    glUniform1i(phong.getUniformLoc("diffuseSampler"), 0);
    glUniform1i(phong.getUniformLoc("specularSampler"), 1);

    mvpLocationPhong = phong.getUniformLoc("mvp");
    modelViewLocationPhong = phong.getUniformLoc("modelView");
    viewLocationPhong = phong.getUniformLoc("view");
    normalLocationPhong = phong.getUniformLoc("normalMatrix");
    
    //initShaderProgram(horse, "shaders/horse.vs.glsl", "shaders/model.fs.glsl");
    ShaderObject vertexG(GL_VERTEX_SHADER, readFile("shaders/gouraud.vs.glsl").c_str());    
    ShaderObject fragmentG(GL_FRAGMENT_SHADER, readFile("shaders/gouraud.fs.glsl").c_str());
    gouraud.attachShaderObject(vertexG);
    gouraud.attachShaderObject(fragmentG);
    gouraud.link();

    gouraud.use();
    glUniform1i(gouraud.getUniformLoc("diffuseSampler"), 0);
    glUniform1i(gouraud.getUniformLoc("specularSampler"), 1);
        
    mvpLocationGouraud = gouraud.getUniformLoc("mvp");
    modelViewLocationGouraud = gouraud.getUniformLoc("modelView");
    viewLocationGouraud = gouraud.getUniformLoc("view");
    normalLocationGouraud = gouraud.getUniformLoc("normalMatrix");

    ShaderObject vertexF(GL_VERTEX_SHADER, readFile("shaders/flat.vs.glsl").c_str());
    ShaderObject geomF(GL_GEOMETRY_SHADER, readFile("shaders/flat.gs.glsl").c_str());
    ShaderObject fragmentF(GL_FRAGMENT_SHADER, readFile("shaders/gouraud.fs.glsl").c_str());
    flat.attachShaderObject(vertexF);
    flat.attachShaderObject(geomF);
    flat.attachShaderObject(fragmentF);
    flat.link();
    
    flat.use();
    glUniform1i(flat.getUniformLoc("diffuseSampler"), 0);
    glUniform1i(flat.getUniformLoc("specularSampler"), 1);
    
    mvpLocationFlat = flat.getUniformLoc("mvp");
    modelViewLocationFlat = flat.getUniformLoc("modelView");
    viewLocationFlat = flat.getUniformLoc("view");
    normalLocationFlat = flat.getUniformLoc("normalMatrix");
}

