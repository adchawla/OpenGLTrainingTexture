//
//  ShaderHelper.m
//  HelloOpenGLES
//
//  Created by Amit Gulati on 14/03/16.
//  Copyright © 2016 Amit Gulati. All rights reserved.
//

#import "ShaderHelper.h"
#import <OPENGLES/ES2/gl.h>

const char* V_SRC = ""
                    "attribute vec4 a_Position;                 \n"
                    "attribute vec4 a_Color;                    \n"
                    "uniform mat4 u_ModelMatrix;                \n"
                    "uniform mat4 u_ProjectionMatrix;           \n"
                    "attribute vec2 a_TextureCoordinate;        \n"
                    "varying vec2 v_TextureCoordinate;          \n"
                    "varying vec4 v_Color;                      \n"
                    "uniform vec4 u_clipPlane;                  \n"
                    "varying float v_distance;                 \n"
                    "void main() {                              \n"
                    "   gl_Position = u_ProjectionMatrix * u_ModelMatrix * a_Position;                  \n"
                    "   v_Color = a_Color;                                                              \n"
                    "   v_TextureCoordinate = a_TextureCoordinate;                                      \n"
                    "   v_distance = dot(gl_Position.xyz, u_clipPlane.xyz) + u_clipPlane.w;              \n"
                    "}";

const char* F_SRC = ""
                    "precision highp float;                         \n"
                    "varying vec4 v_Color;                          \n"
                    "varying vec2 v_TextureCoordinate;              \n"
                    "uniform sampler2D u_ActiveTexture;             \n"
                    "varying float v_distance;                     \n"
                    "void main() {                                  \n"
                    "   if (v_distance < 0.0) { discard; }                                        \n"
                    "   vec4 textureColor = texture2D(u_ActiveTexture, v_TextureCoordinate);    \n"
                    "   gl_FragColor = textureColor;                                            \n"
                    "}";


@interface ShaderHelper ()
-(int) createShaderOfType:(GLenum) type WithSrc:(const char*) src;
@end




@implementation ShaderHelper

-(int) createShaderOfType:(GLenum)type WithSrc:(const char *)src {
    //create Shader object
    int shaderObj = glCreateShader(type);
    if(shaderObj < 0) {
        NSLog(@"Unable to create Shader Object of type %d", type);
        return -1;
    }
    
    //add source code to the shader object
    glShaderSource(shaderObj, 1, &src, 0);
    
    //compile the shader
    glCompileShader(shaderObj);
    
    //get the shader compilation status
    GLint success;
    glGetShaderiv(shaderObj, GL_COMPILE_STATUS, &success);
    if(success == GL_TRUE) {
        NSLog(@"Shader compiled sucessfully");
        return shaderObj;
        
    } else {
        //get the length of the log information from the compiler
        GLint length;
        glGetShaderiv(shaderObj, GL_INFO_LOG_LENGTH, &length);
        
        char* info = (char*)malloc(length);
        GLsizei l;
        glGetShaderInfoLog(shaderObj, length, &l, info);
        printf("COmpiler error %s", info);
        return -1;
        
    }
    return  -1;
}

-(int) createProgramObject {
    int vertshaderObj = [self createShaderOfType:GL_VERTEX_SHADER WithSrc:V_SRC];
    
    int fragShaderObj = [self createShaderOfType:GL_FRAGMENT_SHADER WithSrc:F_SRC];
    
    if(vertshaderObj < 0 || fragShaderObj < 0) {
        return -1;
    }
    
    //create a program object
    int programObject = glCreateProgram();
    
    //attach vertex shader object and fragment shader object to program object
    glAttachShader(programObject, vertshaderObj);
    glAttachShader(programObject, fragShaderObj);
    
    //link shaders
    glLinkProgram(programObject);
    
    //check if linking successful
    GLint success;
    glGetProgramiv(programObject, GL_LINK_STATUS, &success);
    if( success == GL_TRUE ) {
        NSLog(@"Shader Linked Succesfully");
        return programObject;
        
    } else {
        NSLog(@"Shader linking failed");
    }
    
    return -1;
    
    
}





@end
