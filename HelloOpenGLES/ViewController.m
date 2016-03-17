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
-(GLuint) createOffscreenFrameBuffer;
-(void) drawCubeToOffscreenFBO;
-(void) drawCubeToOnscreenFBO;
@end

@implementation ViewController

-(GLuint) createOffscreenFrameBuffer {

    // generate ID for the frameBuffer
    glGenFramebuffers(1, &offscreenFBOID);
    
    // bind to the framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, offscreenFBOID);
    
    // create a texture object which will be attached as color attachment 0.
    glGenTextures(1, &offscreenTextureID);
    glBindTexture(GL_TEXTURE_2D, offscreenTextureID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1024, 1024, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    // attach texture object to the frame buffer as color attachment 0
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, offscreenTextureID, 0);
    
    //create render buffer object and attach it to depth attachment point
    GLuint rboDepth;
    glGenRenderbuffers(1, &rboDepth);
    glBindRenderbuffer(GL_RENDERBUFFER, rboDepth);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, 1024, 1024);
    
    // attach the render buffer object to the frame buffer object
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, rboDepth);
    
    // check the status of frame buffer object
    GLenum success = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if( success == GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"Offscreen Frame Buffer setup correctly");
    } else {
        int error = glGetError();
        NSLog(@"Offscreen FBO Failed with errorCode = %d", error);
        return -1;
    }
    return offscreenFBOID;
    
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self drawCubeToOffscreenFBO];
}

-(void) drawCubeToOffscreenFBO {
    // bind to the offscreen FBO
    glBindFramebuffer(GL_FRAMEBUFFER, offscreenFBOID);
    
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClearDepthf(1.0);
    
    // clear the color buffer and the depth buffer
    glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
    
    // set the view port as per the dimension of frame buffer object
    glViewport(0, 0, 1024, 1024);
    
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, 0, 0, -4);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, GLKMathDegreesToRadians(sunAngle), 1, 1, 1);
    glUniformMatrix4fv(modelMatrixIndex, 1, false, modelMatrix.m);
  
    glUniform1i(useTextureIndex, 0);
    [cube draw];
    
    glFlush();
}

-(void) drawCubeToOnscreenFBO {
    glClearColor(1.0, 1.0, 1.0, 1.0);
    // bind to the onscreen FBO
    // only for iOS to get back to the on screen buffer
    GLKView* view = (GLKView*)self.view;
    [view bindDrawable];
    
    // set the view port as per the dimension of screen
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, 0, 0, -4);
    modelMatrix = GLKMatrix4Rotate(modelMatrix, GLKMathDegreesToRadians(sunAngle), 1, 1, 1);
    glUniformMatrix4fv(modelMatrixIndex, 1, false, modelMatrix.m);

    glUniform1i(useTextureIndex, 0);
    [cube draw];
    
    glFlush();
}

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
    textureCoordinateIndex = glGetAttribLocation(programObject, "a_TextureCoordinate");
    activeTextureIndex = glGetUniformLocation(programObject, "activeTexture");
    modelMatrixIndex = glGetUniformLocation(programObject, "u_ModelMatrix");
    projectionMatrixIndex = glGetUniformLocation(programObject, "u_ProjectionMatrix");
    useTextureIndex = glGetUniformLocation(programObject, "u_UseTexture");

    GLKMatrix4 projectionMatrix = GLKMatrix4Identity;
    float aspect = (float) self.view.bounds.size.width/(float)self.view.bounds.size.height;
    projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), aspect, 0.1, 100.0);
    glUniformMatrix4fv(projectionMatrixIndex, 1, false, projectionMatrix.m);

    cube = [[Cube alloc]initWithProgramObject:programObject];
    sunAngle = 0.0;
    sunRotationIncrement = 0.5;
    
    [self createOffscreenFrameBuffer];
    
    //initialize OpenGL state
    [self initGL];
    
    [self drawCubeToOffscreenFBO];
    glClearColor(1.0, 1.0, 1.0, 1.0 );

}

-(void) initGL {
    
    //set the clear color
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClearDepthf(1.0);
    glEnable(GL_DEPTH_TEST);

    
    //enable texture mapping
    glEnable(GL_TEXTURE_2D);
    
    //upload texture datat ot the GPU
    //textureID = [self loadTexture:@"image4.jpg"];
    
    
    
}

-(void) drawQuad {
    
    glViewport(self.view.frame.size.width, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height);
    
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix, 0, 0, -5);
    glUniformMatrix4fv(modelMatrixIndex, 1, false, modelMatrix.m);
    
    glUniform1i(useTextureIndex, 1);
    
    //make the texture unit 0 active
    glActiveTexture(GL_TEXTURE0);
    
    //bind the textute to active texture unit 0
    glBindTexture(GL_TEXTURE_2D, offscreenTextureID);
    
    //bind the
    
    //tell the fragment shader that texture unit 0 is active
    glUniform1i(activeTextureIndex, 0);
    
    //enable writing to the position variable
    glEnableVertexAttribArray(positionIndex);
    //enable writing to the color variable
    glEnableVertexAttribArray(colorIndex);
    glEnableVertexAttribArray(textureCoordinateIndex);
    
    
    
    glVertexAttribPointer(positionIndex, 3, GL_FLOAT, false, 36, quad_vertices);
    glVertexAttribPointer(colorIndex, 4, GL_FLOAT, false, 36, quad_vertices + 3);
    glVertexAttribPointer(textureCoordinateIndex, 2, GL_FLOAT, false, 36, quad_vertices + 7);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisableVertexAttribArray(positionIndex);
    glDisableVertexAttribArray(colorIndex);
    glDisableVertexAttribArray(textureCoordinateIndex);
    
}



-(void) glkView:(GLKView *)view drawInRect:(CGRect)rect {
    //rendering function'

    //clear the color buffer
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    sunAngle += sunRotationIncrement;
    if (sunAngle >= 360.0) sunAngle = 0.0;
    
    [self drawCubeToOnscreenFBO];
    [self drawQuad];
    
    //flush the opengl pipeline so that the commands get sent to the GPU
    glFlush();
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
