//
//  ViewController.h
//  HelloOpenGLES
//
//  Created by Amit Gulati on 14/03/16.
//  Copyright © 2016 Amit Gulati. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "ShaderHelper.h"
#import "Cube.h"

@interface ViewController : GLKViewController {
    EAGLContext* context;
    ShaderHelper* shaderHelper;
    int programObject;
    
    int positionIndex;
    int colorIndex;
    int modelMatrixIndex;
    int projectionMatrixIndex;
    int textureCoordinateIndex;
    int activeTextureIndex;
    int textureID;
    int useTextureIndex;
    
    GLuint offscreenFBOID;
    GLuint offscreenTextureID;
    
    float sunAngle;
    float sunRotationIncrement;

    Cube *cube;
    
    GLKTextureInfo* backgroundTexture;
}


@end

