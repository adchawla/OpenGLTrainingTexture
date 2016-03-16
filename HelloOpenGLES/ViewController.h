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
#import "Planet1.h"

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
    
    Planet* sun;
    Planet* earth;
    Planet* moon;
}


@end

