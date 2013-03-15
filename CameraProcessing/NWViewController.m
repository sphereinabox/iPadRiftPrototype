//
//  NWViewController.m
//  CameraProcessing
//
//  Created by Nicholas Winters on 12/23/12.
//  Copyright (c) 2012 Nicholas Winters. All rights reserved.
//

#import "NWViewController.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint cubeUniforms[NUM_UNIFORMS];
GLint planeUniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

GLfloat gPlaneVertexData[48] =
{
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,     1.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,     0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,     1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,     1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,     0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,     0.0f, 0.0f,
};

GLfloat gCubeVertexData[288] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,
    //                     normalX, normalY, normalZ,
    //                                                 U,   V,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,     0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,     1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,     0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,     0.0f, 1.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,     1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          1.0f, 0.0f, 0.0f,     1.0f, 1.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,     1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,     0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,     1.0f, 1.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,     1.0f, 1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,     0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,     0.0f, 1.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,    1.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,    0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,    1.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,    1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,    0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,    0.0f, 1.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,    0.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,    1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,    0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,    0.0f, 1.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,    1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,    1.0f, 1.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,     1.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,     0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,     1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,     1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,     0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,     0.0f, 0.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,    1.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,    0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,    1.0f, 1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,    1.0f, 1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,    0.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f,    0.0f, 1.0f
};

GLfloat gCubeMapVertexData[288] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,
    //                     normalX, normalY, normalZ,
    //                                                 U,   V,
    -1.000000f, -1.000000f, 1.000000f,   1.000000f, 0.000000f, -0.000000f, 0.749956f, 0.249999f,
    -1.000000f, -1.000000f, -1.000000f,   1.000000f, 0.000000f, -0.000000f, 0.749957f, 0.499955f,
    -1.000000f, 1.000000f, -1.000000f,   1.000000f, 0.000000f, -0.000000f, 0.500000f, 0.499956f,
    
    -1.000000f, 1.000000f, 1.000000f,   0.000000f, -1.000000f, 0.000000f, 0.499999f, 0.249999f,
    -1.000000f, 1.000000f, -1.000000f,   0.000000f, -1.000000f, 0.000000f, 0.500000f, 0.499956f,
    1.000000f, 1.000000f, -1.000000f,   0.000000f, -1.000000f, 0.000000f, 0.250043f, 0.499956f,
    
    1.000000f, 1.000000f, 1.000000f,   -1.000000f, 0.000000f, 0.000000f, 0.250043f, 0.250000f,
    1.000000f, 1.000000f, -1.000000f,   -1.000000f, 0.000000f, 0.000000f, 0.250043f, 0.499956f,
    1.000000f, -1.000000f, -1.000000f,   -1.000000f, 0.000000f, 0.000000f, 0.000087f, 0.499956f,
    
    1.000000f, -1.000000f, -1.000000f,   -0.000000f, 1.000000f, 0.000000f, 0.999913f, 0.499955f,
    -1.000000f, -1.000000f, -1.000000f,   -0.000000f, 1.000000f, 0.000000f, 0.749957f, 0.499955f,
    1.000000f, -1.000000f, 1.000000f,   -0.000000f, 1.000000f, 0.000000f, 0.999913f, 0.249998f,
    
    -1.000000f, -1.000000f, -1.000000f,   0.000000f, 0.000000f, 1.000000f, 0.500000f, 0.749913f,
    1.000000f, -1.000000f, -1.000000f,   0.000000f, 0.000000f, 1.000000f, 0.250043f, 0.749913f,
    1.000000f, 1.000000f, -1.000000f,   0.000000f, 0.000000f, 1.000000f, 0.250043f, 0.499956f,
    
    1.000000f, -1.000000f, 1.000000f,   0.000000f, 0.000000f, -1.000000f, 0.250042f, 0.000043f,
    -1.000000f, -1.000000f, 1.000000f,   0.000000f, 0.000000f, -1.000000f, 0.499999f, 0.000043f,
    -1.000000f, 1.000000f, 1.000000f,   0.000000f, 0.000000f, -1.000000f, 0.499999f, 0.249999f,
    
    -1.000000f, 1.000000f, 1.000000f,   1.000000f, 0.000000f, -0.000000f, 0.499999f, 0.249999f,
    -1.000000f, -1.000000f, 1.000000f,   1.000000f, 0.000000f, -0.000000f, 0.749956f, 0.249999f,
    -1.000000f, 1.000000f, -1.000000f,   1.000000f, 0.000000f, -0.000000f, 0.500000f, 0.499956f,
    
    1.000000f, 1.000000f, 1.000000f,   0.000000f, -1.000000f, 0.000000f, 0.250043f, 0.250000f,
    -1.000000f, 1.000000f, 1.000000f,   0.000000f, -1.000000f, 0.000000f, 0.499999f, 0.249999f,
    1.000000f, 1.000000f, -1.000000f,   0.000000f, -1.000000f, 0.000000f, 0.250043f, 0.499956f,
    
    1.000000f, -1.000000f, 1.000000f,   -1.000000f, 0.000000f, 0.000000f, 0.000087f, 0.249999f,
    1.000000f, 1.000000f, 1.000000f,   -1.000000f, 0.000000f, 0.000000f, 0.250043f, 0.250000f,
    1.000000f, -1.000000f, -1.000000f,   -1.000000f, 0.000000f, 0.000000f, 0.000087f, 0.499956f,
    
    1.000000f, -1.000000f, 1.000000f,   -0.000000f, 1.000000f, 0.000000f, 0.999913f, 0.249998f,
    -1.000000f, -1.000000f, -1.000000f,   -0.000000f, 1.000000f, 0.000000f, 0.749957f, 0.499955f,
    -1.000000f, -1.000000f, 1.000000f,   -0.000000f, 1.000000f, 0.000000f, 0.749956f, 0.249999f,
    
    -1.000000f, 1.000000f, -1.000000f,   0.000000f, -0.000000f, 1.000000f, 0.500000f, 0.499956f,
    -1.000000f, -1.000000f, -1.000000f,   0.000000f, -0.000000f, 1.000000f, 0.500000f, 0.749913f,
    1.000000f, 1.000000f, -1.000000f,   0.000000f, -0.000000f, 1.000000f, 0.250043f, 0.499956f,
    
    1.000000f, 1.000000f, 1.000000f,   0.000000f, 0.000000f, -1.000000f, 0.250043f, 0.250000f,
    1.000000f, -1.000000f, 1.000000f,   0.000000f, 0.000000f, -1.000000f, 0.250042f, 0.000043f,
    -1.000000f, 1.000000f, 1.000000f,   0.000000f, 0.000000f, -1.000000f, 0.499999f, 0.249999f
};

@interface NWViewController () {    
    GLKMatrix4 _cubeModelViewProjectionMatrix;
    GLKMatrix3 _cubeNormalMatrix;
    float _cubeRotation;
    
    GLKMatrix4 _planeModelViewProjectionMatrix;
    GLKMatrix3 _planeNormalMatrix;
    
    GLuint _cubeProgram;
    GLuint _cubeVertexArray;
    GLuint _cubeVertexBuffer;
    GLuint _cubeTexture;

    GLuint _planeProgram;
    GLuint _planeVertexArray;
    GLuint _planeVertexBuffer;
    GLuint _planeTexture;
    GLuint _planeFrameBuffer; // _planeTexture is rendered-to-texture using _planeFrameBuffer
}
@property (strong, nonatomic) EAGLContext *context;

- (void)setupGL;
- (void)tearDownGL;

- (BOOL)loadSkyboxShaders;
- (BOOL)loadPlaneShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation NWViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [self loadSkyboxShaders];
    [self loadPlaneShaders];
    
    //_cubeTexture = [self setupTexture: @"simpleTexture.png"];
    _cubeTexture = [self setupTexture: @"CubemapCrossSquare.png"];
    
    // we render to _planeTexture using _planeFrameBuffer
    //old: _planeTexture = [self setupTexture: @"Grid.png"];
    int planeTextureWidth = 512;
    int planeTextureHeight = 512;
    glGenTextures(1, &_planeTexture);
    glBindTexture(GL_TEXTURE_2D, _planeTexture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, planeTextureWidth, planeTextureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    GLenum err = glGetError();
    if (err != GL_NO_ERROR)
        NSLog(@"Error uploading texture. glError: 0x%04X", err);


    glGenFramebuffersOES(1, &_planeFrameBuffer);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _planeFrameBuffer);
    // attach renderbuffer
    glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, _planeTexture, 0);
    // unbind frame buffer
    // TODO: is the default framebuffer really 0?
    //?[view bindDrawable]; // glBindFramebufferOES(GL_FRAMEBUFFER_OES, ?);
    //glBindFramebufferOES(GL_FRAMEBUFFER_OES, ?);
    
    
    glEnable(GL_DEPTH_TEST);
    
    // Load vertex array object for cube:
    glGenVertexArraysOES(1, &_cubeVertexArray);
    glBindVertexArrayOES(_cubeVertexArray);
    
    glGenBuffers(1, &_cubeVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _cubeVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeMapVertexData), gCubeMapVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);

    // Load vertex array object for plane:
    glGenVertexArraysOES(1, &_planeVertexArray);
    glBindVertexArrayOES(_planeVertexArray);
    
    glGenBuffers(1, &_planeVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _planeVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gPlaneVertexData), gPlaneVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);

}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_cubeVertexBuffer);
    glDeleteVertexArraysOES(1, &_cubeVertexArray);
    glDeleteTextures(1, &_cubeTexture);

    glDeleteBuffers(1, &_planeVertexBuffer);
    glDeleteVertexArraysOES(1, &_planeVertexArray);
    glDeleteFramebuffers(1, &_planeFrameBuffer);
    glDeleteTextures(1, &_planeTexture);
    
    if (_cubeProgram) {
        glDeleteProgram(_cubeProgram);
        _cubeProgram = 0;
    }
    if (_planeProgram) {
        glDeleteProgram(_planeProgram);
        _planeProgram = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _cubeRotation, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with ES2
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _cubeRotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _cubeNormalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    _cubeModelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    _cubeRotation += self.timeSinceLastUpdate * 0.5f;
    
    // Compute model/view/projection and normal matrix for plane:
    // TODO: rotate plane to face camera?
    // TODO: position plane...
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
//    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, .5f, .5f, .5f);
//    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, M_PI_2, 0.0f, 0.0f, 1.0f);
    _planeNormalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _planeModelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);

    
    // debugging (position cube where plane is)
    //_cubeNormalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    //_cubeModelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _planeFrameBuffer);
    glClearColor(0.35f, 0.35f, 0.85f, 1.0f); // light blue
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    // cheesy hack: just do backface culling. There's no depth buffer now but for the single cube I'm drawing this looks fine.
    glEnable(GL_CULL_FACE);
    glCullFace(GL_BACK);
    
    // Draw cube:
    glBindTexture(GL_TEXTURE_2D, _cubeTexture);

    glBindVertexArrayOES(_cubeVertexArray);
    
    glUseProgram(_cubeProgram);
    
    glUniformMatrix4fv(cubeUniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _cubeModelViewProjectionMatrix.m);
    glUniformMatrix3fv(cubeUniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _cubeNormalMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 36);


    // TODO: is device framebuffer really 0?
    [view bindDrawable]; // glBindFramebufferOES(GL_FRAMEBUFFER_OES, ?);
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f); // gray
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Draw plane:
    glBindTexture(GL_TEXTURE_2D, _planeTexture);
    
    glBindVertexArrayOES(_planeVertexArray);
    
    glUseProgram(_planeProgram);
    
    glUniformMatrix4fv(planeUniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _planeModelViewProjectionMatrix.m);
    glUniformMatrix3fv(planeUniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _planeNormalMatrix.m);
    
    glDrawArrays(GL_TRIANGLES, 0, 6);

}

#pragma mark -  Load Shaders
- (GLuint)setupTexture:(NSString *)fileName
{
    // This method from http://stackoverflow.com/q/7930148/2775
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage)
    {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8,     width*4,CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    GLenum err = glGetError();
    if (err != GL_NO_ERROR)
        NSLog(@"Error uploading texture. glError: 0x%04X", err);
    free(spriteData);
    return texName;
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadSkyboxShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _cubeProgram = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"SkyboxShader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"SkyboxShader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_cubeProgram, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_cubeProgram, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_cubeProgram, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_cubeProgram, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_cubeProgram, GLKVertexAttribTexCoord0, "inputTextureCoordinate");
    
    // Link program.
    if (![self linkProgram:_cubeProgram]) {
        NSLog(@"Failed to link program: %d", _cubeProgram);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_cubeProgram) {
            glDeleteProgram(_cubeProgram);
            _cubeProgram = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    cubeUniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_cubeProgram, "modelViewProjectionMatrix");
    cubeUniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_cubeProgram, "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_cubeProgram, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_cubeProgram, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)loadPlaneShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _planeProgram = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"PlaneShader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"PlaneShader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_planeProgram, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_planeProgram, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_planeProgram, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_planeProgram, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_planeProgram, GLKVertexAttribTexCoord0, "inputTextureCoordinate");
    
    // Link program.
    if (![self linkProgram:_planeProgram]) {
        NSLog(@"Failed to link program: %d", _planeProgram);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_planeProgram) {
            glDeleteProgram(_planeProgram);
            _planeProgram = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    planeUniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_planeProgram, "modelViewProjectionMatrix");
    planeUniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_planeProgram, "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_planeProgram, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_planeProgram, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

@end
