//
//  ViewController.m
//  HelloOpenGLES
//
//  Created by Amit Gulati on 14/03/16.
//  Copyright © 2016 Amit Gulati. All rights reserved.
//

#import "ViewController.h"


float quad_vertices[] = {  0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 1.0,  1, 1,
                          -0.5, 0.5, 0.0, 1.0, 0.0, 0.0, 1.0,  0, 1,
                           0.5, -0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 1, 0,
                          -0.5, -0.5, 0.0, 1.0, 0.0, 0.0, 1.0, 0, 0};


@interface ViewController ()
-(void) initGL;
-(int) loadTexture:(NSString*) fileName;
@end

@implementation ViewController

-(int) loadTexture:(NSString *)fileName {
    //generate the texture ID
    GLuint texture;
    glGenTextures(1, &texture);
    
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    //bind to texture
    glBindTexture(GL_TEXTURE_2D, texture);
 
    //upload sprite image data to the texture objct
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    //specify the minification and maginfication parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    
    //unbind from texture
    glBindTexture(GL_TEXTURE_2D, 0);
    free(spriteData);
    return texture;
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //initialize the rendering context for OpenGL ES 2
    context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    //associate the context with the GLKView
    GLKView* view = (GLKView*)self.view;
    view.context = context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    
    //make the context current or bind to the context
    [EAGLContext setCurrentContext:context];
    
    shaderHelper = [[ShaderHelper alloc] init];
    programObject = [shaderHelper createProgramObject];
    
    if( programObject < 0) {
        NSLog(@"Shader FaileD");
        return;
    } else {
        NSLog(@"Shader executable loaded successfully");
        //load the shader executable on GPU
        glUseProgram(programObject);
    }
    
    
    //get the index for attribute named "a_Position"
    positionIndex = glGetAttribLocation(programObject, "a_Position");
    colorIndex = glGetAttribLocation(programObject, "a_Color");
    modelMatrixIndex = glGetUniformLocation(programObject, "u_ModelMatrix");
    projectionMatrixIndex = glGetUniformLocation(programObject, "u_ProjectionMatrix");
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0, self.view.frame.size.width, 0, self.view.frame.size.height, 0, 1);
    glUniformMatrix4fv(projectionMatrixIndex, 1, false, projectionMatrix.m);
    
    
    
    points = [[NSMutableArray alloc] init];

    //initialize OpenGL state
    [self initGL];
}

-(void) initGL {
    
    //set the clear color
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClearDepthf(1.0);
    
    //enable texture mapping
//    glEnable(GL_TEXTURE_2D);
    
    //upload texture datat ot the GPU
    //textureID = [self loadTexture:@"image4.jpg"];
    
    
    
}

//-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    
//}

-(void) touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //get the touch point
    UITouch* touch = [touches anyObject];
    
    // get the location of touch in view coordinates system
    CGPoint point = [touch locationInView:self.view];
    
    NSValue * value = [NSValue valueWithCGPoint:point];
    [points addObject:value];
}

-(void) drawPoints {
    // write a constant value for the color attribute
    glVertexAttrib4f(colorIndex, 1.0, 0.0, 0.0, 1.0);
    glEnableVertexAttribArray(positionIndex);
    float verticesOfSquare[16];
    for(NSValue* value in points) {
        CGPoint point = [value CGPointValue];
        float x = point.x;
        float y = self.view.frame.size.height - point.y;
        
        verticesOfSquare[0] = x - 4;
        verticesOfSquare[1] = y - 4;
        verticesOfSquare[2] = 0.0;
        verticesOfSquare[3] = 1.0;
        
        verticesOfSquare[4] = x + 4;
        verticesOfSquare[5] = y - 4;
        verticesOfSquare[6] = 0.0;
        verticesOfSquare[7] = 1.0;
        
        verticesOfSquare[8] = x + 4;
        verticesOfSquare[9] = y + 4;
        verticesOfSquare[10] = 0.0;
        verticesOfSquare[11] = 1.0;
        
        verticesOfSquare[12] = x - 4;
        verticesOfSquare[13] = y + 4;
        verticesOfSquare[14] = 0.0;
        verticesOfSquare[15] = 1.0;

        glVertexAttribPointer(positionIndex, 4, GL_FLOAT, false, 0, verticesOfSquare);
        glDrawArrays(GL_LINE_LOOP, 0, 4);
    }
    glDisableVertexAttribArray(positionIndex);
    
}

-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //rendering function'

    //clear the color buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    glUniformMatrix4fv(modelMatrixIndex, 1, false, modelMatrix.m);
    
    [self drawPoints];
    
    //flush the opengl pipeline so that the commands get sent to the GPU
    glFlush();
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
