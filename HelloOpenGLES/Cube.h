//
//  Cube.h
//  HelloOpenGLES
//
//  Created by Amit Gulati on 17/03/16.
//  Copyright © 2016 Amit Gulati. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OPENGLES/ES2/gl.h>
@interface Cube : NSObject{
    int positionIndex;
    int colorIndex;
}

-(id) initWithProgramObject:(GLuint)programObj;
-(void) draw;
@end
