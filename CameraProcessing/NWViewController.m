//
//  NWViewController.m
//  CameraProcessing
//
//  Created by Nicholas Winters on 12/23/12.
//  Copyright (c) 2012 Nicholas Winters. All rights reserved.
//

#import "NWViewController.h"
#import <CoreMotion/CoreMotion.h>


#define BUFFER_OFFSET(i) ((char *)NULL + (i))
#define DEBUG_PLANE_TEXTURE 0

static const int PLANE_TEXTURE_SIZE = 2048;

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
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,     1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,     0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,     0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,     1.0f, 0.0f,
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
    -1.000000f, -1.000000f, 1.000000f,   1.000000f, 0.000000f, -0.000000f, 0.000108f, 0.250021f,
    -1.000000f, -1.000000f, -1.000000f,   1.000000f, 0.000000f, -0.000000f, 0.000108f, 0.499978f,
    -1.000000f, 1.000000f, -1.000000f,   1.000000f, 0.000000f, -0.000000f, 0.250064f, 0.499978f,
    
    -1.000000f, 1.000000f, 1.000000f,   0.000000f, -1.000000f, 0.000000f, 0.250064f, 0.250022f,
    -1.000000f, 1.000000f, -1.000000f,   0.000000f, -1.000000f, 0.000000f, 0.250064f, 0.499978f,
    1.000000f, 1.000000f, -1.000000f,   0.000000f, -1.000000f, 0.000000f, 0.500020f, 0.499978f,
    
    1.000000f, 1.000000f, 1.000000f,   -1.000000f, 0.000000f, 0.000000f, 0.500021f, 0.250022f,
    1.000000f, 1.000000f, -1.000000f,   -1.000000f, 0.000000f, 0.000000f, 0.500020f, 0.499978f,
    1.000000f, -1.000000f, -1.000000f,   -1.000000f, 0.000000f, 0.000000f, 0.749977f, 0.499979f,
    
    1.000000f, -1.000000f, -1.000000f,   -0.000000f, 1.000000f, 0.000000f, 0.749977f, 0.499979f,
    -1.000000f, -1.000000f, -1.000000f,   -0.000000f, 1.000000f, 0.000000f, 0.999935f, 0.499979f,
    1.000000f, -1.000000f, 1.000000f,   -0.000000f, 1.000000f, 0.000000f, 0.749977f, 0.250022f,
    
    -1.000000f, -1.000000f, -1.000000f,   0.000000f, 0.000000f, 1.000000f, 0.250063f, 0.749934f,
    1.000000f, -1.000000f, -1.000000f,   0.000000f, 0.000000f, 1.000000f, 0.500019f, 0.749935f,
    1.000000f, 1.000000f, -1.000000f,   0.000000f, 0.000000f, 1.000000f, 0.500020f, 0.499978f,
    
    1.000000f, -1.000000f, 1.000000f,   0.000000f, 0.000000f, -1.000000f, 0.500021f, 0.000066f,
    -1.000000f, -1.000000f, 1.000000f,   0.000000f, 0.000000f, -1.000000f, 0.250065f, 0.000065f,
    -1.000000f, 1.000000f, 1.000000f,   0.000000f, 0.000000f, -1.000000f, 0.250064f, 0.250022f,
    
    -1.000000f, 1.000000f, 1.000000f,   1.000000f, 0.000000f, -0.000000f, 0.250064f, 0.250022f,
    -1.000000f, -1.000000f, 1.000000f,   1.000000f, 0.000000f, -0.000000f, 0.000108f, 0.250021f,
    -1.000000f, 1.000000f, -1.000000f,   1.000000f, 0.000000f, -0.000000f, 0.250064f, 0.499978f,
    
    1.000000f, 1.000000f, 1.000000f,   0.000000f, -1.000000f, 0.000000f, 0.500021f, 0.250022f,
    -1.000000f, 1.000000f, 1.000000f,   0.000000f, -1.000000f, 0.000000f, 0.250064f, 0.250022f,
    1.000000f, 1.000000f, -1.000000f,   0.000000f, -1.000000f, 0.000000f, 0.500020f, 0.499978f,
    
    1.000000f, -1.000000f, 1.000000f,   -1.000000f, 0.000000f, 0.000000f, 0.749977f, 0.250022f,
    1.000000f, 1.000000f, 1.000000f,   -1.000000f, 0.000000f, 0.000000f, 0.500021f, 0.250022f,
    1.000000f, -1.000000f, -1.000000f,   -1.000000f, 0.000000f, 0.000000f, 0.749977f, 0.499979f,
    
    1.000000f, -1.000000f, 1.000000f,   -0.000000f, 1.000000f, 0.000000f, 0.749977f, 0.250022f,
    -1.000000f, -1.000000f, -1.000000f,   -0.000000f, 1.000000f, 0.000000f, 0.999935f, 0.499979f,
    -1.000000f, -1.000000f, 1.000000f,   -0.000000f, 1.000000f, 0.000000f, 0.999935f, 0.250022f,
    
    -1.000000f, 1.000000f, -1.000000f,   0.000000f, -0.000000f, 1.000000f, 0.250064f, 0.499978f,
    -1.000000f, -1.000000f, -1.000000f,   0.000000f, -0.000000f, 1.000000f, 0.250063f, 0.749934f,
    1.000000f, 1.000000f, -1.000000f,   0.000000f, -0.000000f, 1.000000f, 0.500020f, 0.499978f,
    
    1.000000f, 1.000000f, 1.000000f,   0.000000f, 0.000000f, -1.000000f, 0.500021f, 0.250022f,
    1.000000f, -1.000000f, 1.000000f,   0.000000f, 0.000000f, -1.000000f, 0.500021f, 0.000066f,
    -1.000000f, 1.000000f, 1.000000f,   0.000000f, 0.000000f, -1.000000f, 0.250064f, 0.250022f
};

@interface NWViewController () {
    CMMotionManager* _cmMotionmanager;

    GLuint _simpleTexture;

    GLKMatrix4 _projectionMatrix;
    GLKMatrix4 _baseModelViewMatrix;
    
    // Skybox:
    GLKMatrix4 _skyboxModelViewProjectionMatrix;
    GLKMatrix3 _skyboxNormalMatrix;
    GLuint _skyboxProgram;
    GLuint _skyboxVertexArray;
    GLuint _skyboxVertexBuffer;
    GLuint _skyboxTexture;
    
    // Cubes!
    GLuint _cubeVertexArray;
    GLuint _cubeVertexBuffer;

    GLKMatrix4 _planeModelViewProjectionMatrixLeft;
    GLKMatrix3 _planeNormalMatrixLeft;
    GLKMatrix4 _planeModelViewProjectionMatrixRight;
    GLKMatrix3 _planeNormalMatrixRight;
    GLuint _planeProgram;
    GLuint _planeVertexArray;
    GLuint _planeVertexBuffer;
    GLuint _planeTextureLeft;
    GLuint _planeFrameBufferLeft; // _planeTexture is rendered-to-texture using _planeFrameBuffer
    GLuint _planeDepthBufferLeft;
    GLuint _planeTextureRight;
    GLuint _planeFrameBufferRight; // _planeTexture is rendered-to-texture using _planeFrameBuffer
    GLuint _planeDepthBufferRight;
    
    float _gameTime;
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
    _cmMotionmanager = [[CMMotionManager alloc] init];
    [_cmMotionmanager startDeviceMotionUpdates];

    [EAGLContext setCurrentContext:self.context];
    
    [self loadSkyboxShaders];
    [self loadPlaneShaders];
    
    //_cubeTexture = [self setupTexture: @"simpleTexture.png"];
    _skyboxTexture = [self setupTexture: @"CubemapCrossSquare.png"];
    _simpleTexture = [self setupTexture:@"simpleTexture.png"];
    
    // we render to _planeTexture using _planeFrameBuffer
#if DEBUG_PLANE_TEXTURE == 1
    _planeTexture = [self setupTexture: @"Grid.png"];
#else
    int planeTextureWidth = PLANE_TEXTURE_SIZE;
    int planeTextureHeight = PLANE_TEXTURE_SIZE;

    glGenTextures(1, &_planeTextureLeft);
    glBindTexture(GL_TEXTURE_2D, _planeTextureLeft);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, planeTextureWidth, planeTextureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    GLenum err = glGetError();
    if (err != GL_NO_ERROR)
        NSLog(@"Error uploading texture. glError: 0x%04X", err);
    glGenFramebuffersOES(1, &_planeFrameBufferLeft);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _planeFrameBufferLeft);
    // attach renderbuffer
    glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, _planeTextureLeft, 0);
    
    glGenRenderbuffers(1, &_planeDepthBufferLeft);
    glBindRenderbuffer(GL_RENDERBUFFER, _planeDepthBufferLeft);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, planeTextureWidth, planeTextureHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _planeDepthBufferLeft);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status != GL_FRAMEBUFFER_COMPLETE)
        NSLog(@"Framebuffer status: %x", (int)status);
    
    glGenTextures(1, &_planeTextureRight);
    glBindTexture(GL_TEXTURE_2D, _planeTextureRight);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, planeTextureWidth, planeTextureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    GLenum err2 = glGetError();
    if (err2 != GL_NO_ERROR)
        NSLog(@"Error uploading texture. glError: 0x%04X", err2);
    glGenFramebuffersOES(1, &_planeFrameBufferRight);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _planeFrameBufferRight);
    // attach renderbuffer
    glFramebufferTexture2DOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_TEXTURE_2D, _planeTextureRight, 0);
    
    glGenRenderbuffers(1, &_planeDepthBufferRight);
    glBindRenderbuffer(GL_RENDERBUFFER, _planeDepthBufferRight);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, planeTextureWidth, planeTextureHeight);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _planeDepthBufferRight);
    
    GLenum status2 = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if(status2 != GL_FRAMEBUFFER_COMPLETE)
        NSLog(@"Framebuffer status: %x", (int)status2);
#endif
    
    glEnable(GL_DEPTH_TEST);
    
    // Load vertex array object for skybox:
    glGenVertexArraysOES(1, &_skyboxVertexArray);
    glBindVertexArrayOES(_skyboxVertexArray);
    
    glGenBuffers(1, &_skyboxVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _skyboxVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeMapVertexData), gCubeMapVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);

    // Load vertex array object for cube:
    glGenVertexArraysOES(1, &_cubeVertexArray);
    glBindVertexArrayOES(_cubeVertexArray);
    
    glGenBuffers(1, &_cubeVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _cubeVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gCubeVertexData), gCubeVertexData, GL_STATIC_DRAW);
    
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

    self.preferredFramesPerSecond = 60;
}

- (void)tearDownGL
{
    [_cmMotionmanager stopDeviceMotionUpdates];

    [EAGLContext setCurrentContext:self.context];

    glDeleteTextures(1, &_simpleTexture);
    
    glDeleteBuffers(1, &_skyboxVertexBuffer);
    glDeleteVertexArraysOES(1, &_skyboxVertexArray);
    glDeleteTextures(1, &_skyboxTexture);

    glDeleteBuffers(1, &_planeVertexBuffer);
    glDeleteVertexArraysOES(1, &_planeVertexArray);
    glDeleteRenderbuffers(1, &_planeDepthBufferLeft);
    glDeleteFramebuffers(1, &_planeFrameBufferLeft);
    glDeleteTextures(1, &_planeTextureLeft);
    glDeleteRenderbuffers(1, &_planeDepthBufferRight);
    glDeleteFramebuffers(1, &_planeFrameBufferRight);
    glDeleteTextures(1, &_planeTextureRight);
    
    if (_skyboxProgram) {
        glDeleteProgram(_skyboxProgram);
        _skyboxProgram = 0;
    }
    if (_planeProgram) {
        glDeleteProgram(_planeProgram);
        _planeProgram = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float invScale = 1.0f; // ipad 9.7" display
    //float invScale = 0.814f; // ipad mini 7.9" display
    
    // Plane matricies:
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 planeProjectionMatrix = GLKMatrix4MakeOrtho(-aspect*invScale, aspect*invScale, -invScale, invScale, -invScale, invScale);
    float planeScale = 2.0f*0.7f; // 2.0 will scale plane to vertical height of screen
    float planeEyeOffsetX = 2.0f*.15f; // offset from center. 1.0 would offset by vertical height of screen
    float planeEyeOffsetY = -0.05f;
    // Left eye:
    GLKMatrix4 planeModelViewMatrix = GLKMatrix4MakeTranslation(-planeEyeOffsetX, planeEyeOffsetY, 0.0f);
    planeModelViewMatrix = GLKMatrix4Scale(planeModelViewMatrix, planeScale, planeScale, planeScale);
    _planeNormalMatrixLeft = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(planeModelViewMatrix), NULL);
    _planeModelViewProjectionMatrixLeft = GLKMatrix4Multiply(planeProjectionMatrix, planeModelViewMatrix);
    // Right:
    planeModelViewMatrix = GLKMatrix4MakeTranslation(planeEyeOffsetX, planeEyeOffsetY, 0.0f);
    planeModelViewMatrix = GLKMatrix4Scale(planeModelViewMatrix, planeScale, planeScale, planeScale);
    _planeNormalMatrixRight = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(planeModelViewMatrix), NULL);
    _planeModelViewProjectionMatrixRight = GLKMatrix4Multiply(planeProjectionMatrix, planeModelViewMatrix);
    
    GLKMatrix4 deviceMotionAttitudeMatrix;
    if (_cmMotionmanager.deviceMotionActive) {
        CMDeviceMotion *deviceMotion = _cmMotionmanager.deviceMotion;
    
        // Correct for the rotation matrix not including the device orientation:
        // TODO: Let the device notify me when the orientation changes instead of querying on each update.
        UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
        float deviceOrientationRadians = 0.0f;
        if (orientation == UIDeviceOrientationLandscapeLeft) {
            deviceOrientationRadians = M_PI_2;
        }
        if (orientation == UIDeviceOrientationLandscapeRight) {
            deviceOrientationRadians = -M_PI_2;
        }
        if (orientation == UIDeviceOrientationPortraitUpsideDown) {
            deviceOrientationRadians = M_PI;
        }
        GLKMatrix4 baseRotation = GLKMatrix4MakeRotation(deviceOrientationRadians, 0.0f, 0.0f, 1.0f);
        
        // Note: in the simulator this comes back as the zero matrix.
        // on device, this doesn't include the changes required to match screen rotation.
        CMRotationMatrix a = deviceMotion.attitude.rotationMatrix;
        deviceMotionAttitudeMatrix
            = GLKMatrix4Make(a.m11, a.m21, a.m31, 0.0f,
                             a.m12, a.m22, a.m32, 0.0f,
                             a.m13, a.m23, a.m33, 0.0f,
                             0.0f, 0.0f, 0.0f, 1.0f);
        deviceMotionAttitudeMatrix = GLKMatrix4Multiply(baseRotation, deviceMotionAttitudeMatrix);
    }
    else
    {
        // Look straight forward (we're probably in the simulator, or a device without a gyro)
        deviceMotionAttitudeMatrix = GLKMatrix4MakeRotation(-M_PI_2, 1.0f, 0.0f, 0.0f);
    }
    
    // Cube matricies:
    _projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(115.0f), 1.0f, 0.1f, 100.0f);
    
    _baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
    _baseModelViewMatrix = GLKMatrix4Multiply(_baseModelViewMatrix, deviceMotionAttitudeMatrix);

    const float skyboxScale = 10.0f;
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeScale(skyboxScale, skyboxScale, skyboxScale);
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, 0.0f, 0.0f, 0.0f);
    modelViewMatrix = GLKMatrix4Multiply(_baseModelViewMatrix, modelViewMatrix);
    
    _skyboxNormalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    _skyboxModelViewProjectionMatrix = GLKMatrix4Multiply(_projectionMatrix, modelViewMatrix);
    
    _gameTime += self.timeSinceLastUpdate;
}

- (void)drawWorldWithEyeOffset:(float)eyeOffset
{
    glClearColor(0.35f, 0.35f, 0.85f, 1.0f); // light blue
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Draw skybox:
    glBindTexture(GL_TEXTURE_2D, _skyboxTexture);
    glBindVertexArrayOES(_skyboxVertexArray);
    glUseProgram(_skyboxProgram);
    glUniformMatrix4fv(cubeUniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _skyboxModelViewProjectionMatrix.m);
    glUniformMatrix3fv(cubeUniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _skyboxNormalMatrix.m);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    
    GLKMatrix4 temp = GLKMatrix4MakeTranslation(eyeOffset, 0.0f, 0.0f);
    GLKMatrix4 eyeBaseModelViewMatrix = GLKMatrix4Multiply(temp, _baseModelViewMatrix);
    
    // draw a floor of cubes!
    glBindTexture(GL_TEXTURE_2D, _simpleTexture);
    glBindVertexArrayOES(_cubeVertexArray);
    glUseProgram(_skyboxProgram);
    for (int x = -10; x < 10; x++) {
        for (int y = -10; y < 10; y++) {
            // Cube matricies:
            const float cubeScale = 0.8f;
            GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation((float)x, (float)y, -1.5f);
            modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, cubeScale, cubeScale, cubeScale);
            modelViewMatrix = GLKMatrix4Multiply(eyeBaseModelViewMatrix, modelViewMatrix);
            
            GLKMatrix3 normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
            GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(_projectionMatrix, modelViewMatrix);
            
            glUniformMatrix4fv(cubeUniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, modelViewProjectionMatrix.m);
            glUniformMatrix3fv(cubeUniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
            glDrawArrays(GL_TRIANGLES, 0, 36);
        }
    }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
#if DEBUG_PLANE_TEXTURE == 1
#else
    const float ipd = 0.065f; // Typical pupil distance values are 50-70mm
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _planeFrameBufferLeft);
    glViewport(0, 0, PLANE_TEXTURE_SIZE, PLANE_TEXTURE_SIZE);
    [self drawWorldWithEyeOffset: -0.5f*ipd];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, _planeFrameBufferRight);
    glViewport(0, 0, PLANE_TEXTURE_SIZE, PLANE_TEXTURE_SIZE);
    [self drawWorldWithEyeOffset: 0.5f*ipd];
#endif

    [view bindDrawable]; // glBindFramebufferOES(GL_FRAMEBUFFER_OES, ?);
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f); // gray
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Draw plane:
    glBindVertexArrayOES(_planeVertexArray);
    glUseProgram(_planeProgram);
    int width = [view drawableWidth];
    int height = [view drawableHeight];
    glEnable(GL_SCISSOR_TEST);
    
    // left eye:
    glBindTexture(GL_TEXTURE_2D, _planeTextureLeft);
    glScissor(0, 0, width/2, height);
    glUniformMatrix4fv(planeUniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _planeModelViewProjectionMatrixLeft.m);
    glUniformMatrix3fv(planeUniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _planeNormalMatrixLeft.m);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    // right eye:
    glBindTexture(GL_TEXTURE_2D, _planeTextureRight);
    glScissor(width/2, 0, width/2, height);
    glUniformMatrix4fv(planeUniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _planeModelViewProjectionMatrixRight.m);
    glUniformMatrix3fv(planeUniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _planeNormalMatrixRight.m);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    glDisable(GL_SCISSOR_TEST);
}

#pragma mark -  Load Shaders
- (GLuint)setupTexture:(NSString *)fileName
{
    // This method from http://stackoverflow.com/q/7930148/2775
    // TODO: see if this is flipping the texture across the Y axis.
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
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    GLenum err = glGetError();
    if (err != GL_NO_ERROR)
        NSLog(@"Error uploading texture. glError: 0x%04X", err);
    free(spriteData);
    
    glGenerateMipmap(GL_TEXTURE_2D);
    
    return texName;
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadSkyboxShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _skyboxProgram = glCreateProgram();
    
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
    glAttachShader(_skyboxProgram, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_skyboxProgram, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_skyboxProgram, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_skyboxProgram, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(_skyboxProgram, GLKVertexAttribTexCoord0, "inputTextureCoordinate");
    
    // Link program.
    if (![self linkProgram:_skyboxProgram]) {
        NSLog(@"Failed to link program: %d", _skyboxProgram);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_skyboxProgram) {
            glDeleteProgram(_skyboxProgram);
            _skyboxProgram = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    cubeUniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_skyboxProgram, "modelViewProjectionMatrix");
    cubeUniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_skyboxProgram, "normalMatrix");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_skyboxProgram, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_skyboxProgram, fragShader);
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
