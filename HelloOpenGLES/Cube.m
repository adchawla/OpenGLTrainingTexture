//
//  Cube.m
//  HelloOpenGLES
//
//  Created by Amit Gulati on 17/03/16.
//  Copyright © 2016 Amit Gulati. All rights reserved.
//

#import "Cube.h"
const float Vertices[] = {
    1.0,  1.0,  1.0,     1.0,  1.0,  1.0,  // v0 White
    -1.0,  1.0,  1.0,     1.0,  0.0,  1.0,  // v1 Magenta
    -1.0, -1.0,  1.0,     1.0,  0.0,  0.0,  // v2 Red
    1.0, -1.0,  1.0,     1.0,  1.0,  0.0,  // v3 Yellow
    1.0, -1.0, -1.0,     0.0,  1.0,  0.0,  // v4 Green
    1.0,  1.0, -1.0,     0.0,  1.0,  1.0,  // v5 Cyan
    -1.0,  1.0, -1.0,     0.0,  0.0,  1.0,  // v6 Blue
    -1.0, -1.0, -1.0,     0.0,  0.0,  0.0   // v7 Black
};

const GLubyte Indices[] = {
    0, 1, 2,   0, 2, 3,    // front
    0, 3, 4,   0, 4, 5,    // right
    0, 5, 6,   0, 6, 1,    // up
    1, 6, 7,   1, 7, 2,    // left
    7, 4, 3,   7, 3, 2,    // down
    4, 7, 6,   4, 6, 5     // back
};
@implementation Cube

-(id) initWithProgramObject:(GLuint)programObj {
    self = [super init];
    if(self) {
        positionIndex = glGetAttribLocation(programObj, "a_Position");
        colorIndex = glGetAttribLocation(programObj, "a_Color");
    }
    
    return self;
}

-(void) draw {
    glEnableVertexAttribArray(positionIndex);
    glEnableVertexAttribArray(colorIndex);
    glVertexAttribPointer(positionIndex, 3, GL_FLOAT, false, 24, Vertices);
    glVertexAttribPointer(colorIndex, 3, GL_FLOAT, false, 24, Vertices + 3);
    glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_BYTE, Indices);
    glDisableVertexAttribArray(positionIndex);
    glDisableVertexAttribArray(colorIndex);
    
}

@end
