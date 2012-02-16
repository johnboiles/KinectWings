/**
 *  @file GLViewController.h
 *
 * Copyright 2009 Parrot SA. All rights reserved.
 * @author D HAEYER Frederic
 * @date 2009/10/26
 */
#include "ConstantsAndMacros.h"

#import "OpenGLVideo.h"
#import "OpenGLSprite.h"
#import "ARDrone.h"
#import "InternalProtocols.h"
#import <AppKit/AppKit.h>

typedef struct
{
	GLint depthFunc;
	GLboolean depthWriteMask;
	GLint textureBinding2D;
	GLint textureEnvMode;
	GLint blendSrc;
	GLint blendDst;
	GLint clientActiveTexture;
	GLboolean depthTest;
	GLboolean cullFace;
	GLboolean texture2D;
	GLboolean blend;
	GLboolean lighting;
	GLboolean vertexArray;
	GLboolean textureCoordArray;
	GLboolean colorArray;
	GLboolean normalArray;
	GLfloat linewidth;
} OpenGLContext;

@class OpenGLVideo;

@interface GLViewController : NSOpenGLView {
@private
	OpenGLVideo   *video;
	id delegate;
  OpenGLContext openGLContext;
}

- (void)drawView;

@end
