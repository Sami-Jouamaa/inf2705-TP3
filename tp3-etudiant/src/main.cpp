#include <iostream>

#include <GL/glew.h>

#include "imgui/imgui.h"

#include "window.h"
#include "resources.h"

#include "scenes/scene_lighting.h"

#include "corrector.h"

void printGLInfo();

int main(int argc, char* argv[])
{
    Window w;
    if (!w.init())
        return -1;
    
    GLenum rev = glewInit();
    if (rev != GLEW_OK)
    {
        std::cout << "Could not initialize glew! GLEW_Error: " << glewGetErrorString(rev) << std::endl;
        return -2;
    }
        
    printGLInfo();
    
    //corrector(w);
    
    bool isMouseMotionEnabled = false;    
    bool isThirdPerson = false;
    bool isOrtho = false;
    
    Resources res;
    
    SceneLighting s1(res, isMouseMotionEnabled);
    
    glClearColor(0.75f, 0.95f, 0.95f, 1.0f);
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    const char* const SCENE_NAMES[] = {
        "Lighting",
    };
    const int N_SCENE_NAMES = sizeof(SCENE_NAMES) / sizeof(SCENE_NAMES[0]);
    int currentScene = 0;
    
    bool isRunning = true;
    while (isRunning)
    {
        if (w.shouldResize())
            glViewport(0, 0, w.getWidth(), w.getHeight());
        
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
        
        // Plus besoin de ce menu, on a qu'une seule scène
        //ImGui::Begin("Scene Parameters");
        //ImGui::Combo("Scene", &currentScene, SCENE_NAMES, N_SCENE_NAMES);
        //ImGui::End();
        
        if (w.getKeyPress(Window::Key::SPACE))
            isMouseMotionEnabled = !isMouseMotionEnabled;
            
        if (isMouseMotionEnabled)
            w.hideMouse();
        else
            w.showMouse();
        
        if (w.getKeyPress(Window::Key::T))
            currentScene = ++currentScene < N_SCENE_NAMES ? currentScene : 0;
        
        switch (currentScene)
        {
            case 0: s1.run(w); break;
        }       
        
        w.swap();
        w.pollEvent();
        isRunning = !w.shouldClose() && !w.getKeyPress(Window::Key::ESC);
    }

    return 0;
}


void printGLInfo()
{
    std::cout << "OpenGL info:"          << std::endl;
    std::cout << "    Vendor: "          << glGetString(GL_VENDOR)                   << std::endl;
    std::cout << "    Renderer: "        << glGetString(GL_RENDERER)                 << std::endl;
    std::cout << "    Version: "         << glGetString(GL_VERSION)                  << std::endl;
    std::cout << "    Shading version: " << glGetString(GL_SHADING_LANGUAGE_VERSION) << std::endl;
}


