//
//  JBAppDelegate.m
//  KinectWings
//
//  Created by John Boiles on 1/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JBAppDelegate.h"
#import <OpenGL/gl.h>
#include <XnCppWrapper.h>
#import <QuartzCore/QuartzCore.h>
#include <GLUT/glut.h>

@implementation JBAppDelegate

@synthesize window = _window;

- (void)dealloc
{
  [super dealloc];
}

- (void)display {
  [_openGLView setNeedsDisplay:YES];
}

- (void)initOpenGL {
	glDisable(GL_DEPTH_TEST);
	glEnable(GL_TEXTURE_2D);

	glEnableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_COLOR_ARRAY);

  _openGLView.started = YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [[CocoaOpenNI sharedOpenNI] start];
  [self initOpenGL];
  // XXX(johnb): I think I'm supposed to do this with CADisplayLink or something like that. This seems ghetto
  [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(display) userInfo:nil repeats:YES];
}

@end
