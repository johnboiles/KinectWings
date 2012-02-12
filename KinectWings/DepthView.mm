//
//  DepthView.m
//  KinectWings
//
//  Created by John Boiles on 1/13/12.
//  Copyright (c) 2012 John Boiles. All rights reserved.
//

#import "DepthView.h"
#import <OpenGL/gl.h>
#import "CocoaOpenNI.h"
#include <XnCppWrapper.h>

#define kKinectWidth (640.0)
#define kKinectHeight (480.0)

static void drawTriangle() {
  glColor3f(1.0f, 0.85f, 0.35f);
  glBegin(GL_TRIANGLES);
  {
    glVertex3f(  0.0,  0.6, 0.0);
    glVertex3f( -0.2, -0.3, 0.0);
    glVertex3f(  0.2, -0.3 ,0.0);
  }
  glEnd();
}

@implementation DepthView

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

	glOrtho(0.0f, kKinectWidth, kKinectHeight, 0.0f, -1.0f, 1.0f);
}

- (void)setFrame:(NSRect)frameRect {
  [self setup];
  [super setFrame:frameRect];
}

- (void)drawRect:(NSRect)bounds {
  if ([[CocoaOpenNI sharedOpenNI] isStarted]) {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    xn::SceneMetaData sceneMD;
    xn::DepthMetaData depthMD;
    [[CocoaOpenNI sharedOpenNI] depthGenerator].GetMetaData(depthMD);

    glDisable(GL_TEXTURE_2D);

    // Read next available data
    // If we skip this, the view will appear paused
    [[CocoaOpenNI sharedOpenNI] context].WaitNoneUpdateAll();

    // Process the data
    [[CocoaOpenNI sharedOpenNI] depthGenerator].GetMetaData(depthMD);
    [[CocoaOpenNI sharedOpenNI] userGenerator].GetUserPixels(0, sceneMD);
    DrawDepthMap(depthMD, sceneMD);
    DrawUserInfo();

    // TODO(johnb): I wonder what the difference in swapping buffers and flushing is
    //glutSwapBuffers();
    glFlush();
  } else {
    // Draw a triangle. Why the hell not?
    glClearColor(0, 0, 0, 0);
    glClear(GL_COLOR_BUFFER_BIT);
    drawTriangle();
    glFlush();
  }
}

@end
