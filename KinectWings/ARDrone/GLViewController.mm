/**
 *  @file GLViewController.m
 *
 * Copyright 2009 Parrot SA. All rights reserved.
 * @author D HAEYER Frederic
 * @date 2009/10/26
 */
#include "ConstantsAndMacros.h"
#import "GLViewController.h"
#import <OpenGl/gl.h>
#import "DepthView.h"
#import "CocoaOpenNI.h"

static void drawTriangle();

static CGFloat const matrixOrthoFront[] = {1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, -1.0f, 1.0f};
static CGFloat const matrixOrthoBack[] = {1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f};

static GLfloat const matrixOrthoBackLeft[] = {1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f};
static GLfloat const matrixOrthoBackRight[] = {-1.0f, 0.0f, 0.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, 1.0f};

float normalize_vector(float x, float y, float z);

float normalize_vector(float x, float y, float z)
{
	return sqrtf((x * x) + (y  * y) + (z * z));
}

@interface GLViewController ()
- (void)saveOpenGLContext;
- (void)restoreOpenGLContext;
@end

@implementation GLViewController

- (id)initWithFrame:(NSRect)frameRect {
  if ((self = [super initWithFrame:frameRect])) {
    NSLog(@"Frame : %f, %f", frameRect.size.width, frameRect.size.height);

    video = [[OpenGLVideo alloc] initWithPath:[[NSBundle mainBundle] pathForResource:@"background" ofType:@"png"] withScreenSize:NSSizeToCGSize(frameRect.size)];
  }

  return self;
}

- (void)saveOpenGLContext {
	// Make sure the client active texture is the same as the server active texture
	GLint activeTexture;
	glGetIntegerv(GL_ACTIVE_TEXTURE, &activeTexture);	
	glGetIntegerv(GL_CLIENT_ACTIVE_TEXTURE, &openGLContext.clientActiveTexture);
	glClientActiveTexture(activeTexture);

	// Save OpenGL parameters that have been modified
	glGetIntegerv(GL_DEPTH_FUNC, &openGLContext.depthFunc);
	glGetBooleanv(GL_DEPTH_WRITEMASK, &openGLContext.depthWriteMask);
	glGetIntegerv(GL_TEXTURE_BINDING_2D, &openGLContext.textureBinding2D);
	glGetTexEnviv(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, &openGLContext.textureEnvMode);
	glGetIntegerv(GL_BLEND_SRC, &openGLContext.blendSrc);
	glGetIntegerv(GL_BLEND_DST, &openGLContext.blendDst);
	glGetFloatv(GL_LINE_WIDTH, &openGLContext.linewidth);
	
	openGLContext.depthTest = glIsEnabled(GL_DEPTH_TEST);
	openGLContext.cullFace = glIsEnabled(GL_CULL_FACE);
	openGLContext.texture2D = glIsEnabled(GL_TEXTURE_2D);
	openGLContext.blend = glIsEnabled(GL_BLEND);
	openGLContext.lighting = glIsEnabled(GL_LIGHTING);
	openGLContext.vertexArray = glIsEnabled(GL_VERTEX_ARRAY);
	openGLContext.textureCoordArray = glIsEnabled(GL_TEXTURE_COORD_ARRAY);
	openGLContext.colorArray = glIsEnabled(GL_COLOR_ARRAY);
	openGLContext.normalArray = glIsEnabled(GL_NORMAL_ARRAY);
}

- (void)restoreOpenGLContext {
	// Restore OpenGL parameters that have been modified
	openGLContext.normalArray ? glEnableClientState(GL_NORMAL_ARRAY) : glDisableClientState(GL_NORMAL_ARRAY);
	openGLContext.colorArray ? glEnableClientState(GL_COLOR_ARRAY) : glDisableClientState(GL_COLOR_ARRAY);
	openGLContext.textureCoordArray ? glEnableClientState(GL_TEXTURE_COORD_ARRAY) : glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	openGLContext.vertexArray ? glEnableClientState(GL_VERTEX_ARRAY) : glDisableClientState(GL_VERTEX_ARRAY);
	
	openGLContext.lighting ? glEnable(GL_LIGHTING) : glDisable(GL_LIGHTING);
	openGLContext.blend ? glEnable(GL_BLEND) : glDisable(GL_BLEND);
	openGLContext.texture2D ? glEnable(GL_TEXTURE_2D) : glDisable(GL_TEXTURE_2D);
	openGLContext.cullFace ? glEnable(GL_CULL_FACE) : glDisable(GL_CULL_FACE);
	openGLContext.depthTest ? glEnable(GL_DEPTH_TEST) : glDisable(GL_DEPTH_TEST);
	
	glBlendFunc(openGLContext.blendSrc, openGLContext.blendDst);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, openGLContext.textureEnvMode);
	glBindTexture(GL_TEXTURE_2D, openGLContext.textureBinding2D);
	glDepthMask(openGLContext.depthWriteMask);
	glDepthFunc(openGLContext.depthFunc);
	glLineWidth(openGLContext.linewidth);

	// Make sure the client active texture is the same as the server active texture
	glClientActiveTexture(openGLContext.clientActiveTexture);
}

static DepthView *depthView = NULL;
- (void)drawView
{	
	// Save OpenGLContext
	[self saveOpenGLContext];
	
	// Setup the quad
  glClearColor(0, 0, 0, 0);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
	glDepthFunc(GL_LEQUAL);
	glDepthMask(GL_FALSE);
	glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
	glBlendFunc(GL_ONE, GL_ONE);

	glEnable(GL_DEPTH_TEST);
	glDisable(GL_CULL_FACE);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glDisable(GL_LIGHTING);

	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_NORMAL_ARRAY);

	// Set the projection matrix for the background elements
	glMatrixMode(GL_PROJECTION);
	glPushMatrix();
	glLoadIdentity();
  BOOL screenOrientationRight = YES;
	glMultMatrixf(matrixOrthoBackRight);

  glViewport(0, 0, self.frame.size.width, self.frame.size.height);
  //glOrtho(0.0f, 640, 480, 0.0f, -1.0f, 1.0f);

	// Set the model view matrix
	glMatrixMode(GL_MODELVIEW);
	glPushMatrix();
	glLoadIdentity();

	// Set the texture matrix
	glMatrixMode(GL_TEXTURE);
	glPushMatrix();
	glLoadIdentity();

	// Bind the background texture
	// Draw video
	[video drawSelf];
	// Restore the model view matrix
	glMatrixMode(GL_TEXTURE);
	glPopMatrix();

	// Restore the model view matrix
	glMatrixMode(GL_MODELVIEW);
	glPopMatrix();

	// Restore the projection matrix
	glMatrixMode(GL_PROJECTION);
	glPopMatrix();

	// Restore OpenGL context if modified
	[self restoreOpenGLContext];
  if ([CocoaOpenNI sharedOpenNI].started) {
    if (!depthView) {
      depthView = [[DepthView alloc] init];
    }
    [depthView drawRect:NSZeroRect];
  }
}

- (void)dealloc {
	[video release];
	[super dealloc];
}


- (void)setup {
  glDisable(GL_DEPTH_TEST);
  glEnable(GL_TEXTURE_2D);
  glEnableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);
  
  // Setup the OpenGL viewpoint
  glMatrixMode(GL_PROJECTION);
  glPushMatrix();
  glLoadIdentity();
  
  glViewport(0, 0, self.frame.size.width, self.frame.size.height);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
  
	glOrtho(0.0f, 640, 480, 0.0f, -1.0f, 1.0f);
}

- (void)setFrame:(NSRect)frameRect {
  [self setup];
  [super setFrame:frameRect];
}

- (void)drawRect:(NSRect)bounds {
  //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  [self drawView];
}


@end
